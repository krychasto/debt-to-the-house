extends Control

const DEFAULT_BET := 10
const CARD_SIZE := Vector2(92, 126)
const TABLE_TEXTURE := preload("res://assets/ui/table_felt.png")
const CARD_BACK_TEXTURE := preload("res://assets/ui/card_back.png")
const CARD_FRONT_TEXTURE := preload("res://assets/ui/card_front.png")
const CARD_HOVER_OFFSET := Vector2(0, -8)
const CARD_ENTER_TIME := 0.18
const CARD_HOVER_TIME := 0.10
const CARD_TILT_RANGE := 2.5
const RELIC_DRAWER_WIDTH := 286.0
const CHIP_SIZE := Vector2(42, 42)
const CHIP_RADIUS := 21.0
const CHIP_COLLISION_RADIUS := 18.0
const CHIP_ATTRACTION := 7.0
const CHIP_FRICTION := 0.12
const CHIP_BOUNCE := 0.55
const GOLD := Color(1.0, 0.78, 0.16)
const CYAN := Color(0.18, 0.94, 0.88)
const PINK := Color(1.0, 0.18, 0.55)
const INK := Color(0.03, 0.01, 0.05)

var engine: BlackjackEngine = BlackjackEngine.new()
var run_manager: RunManager = RunManager.new()

var stage_label: Label
var money_label: Label
var hands_label: Label
var debt_label: Label
var combo_label: Label
var dealer_score_label: Label
var player_score_label: Label
var synergy_panel: PanelContainer
var synergy_list: VBoxContainer
var dealer_cards_row: HBoxContainer
var player_cards_row: HBoxContainer
var message_label: Label
var bet_input: SpinBox
var decrease_bet_button: Button
var increase_bet_button: Button
var max_bet_button: Button
var deal_button: Button
var hit_button: Button
var stand_button: Button
var retry_button: Button
var relics_button: Button
var relic_drawer_panel: PanelContainer
var relic_drawer_list: VBoxContainer
var reward_panel: PanelContainer
var reward_overlay: Control
var reward_cards_row: HBoxContainer
var reward_message_label: Label
var table_area_root: VBoxContainer
var background_shade: ColorRect
var chip_layer: Control
var flash_overlay: ColorRect
var result_burst_label: Label
var active_chips: Array[Control] = []
var reward_buttons: Array[Button] = []
var reward_card_views: Array[Control] = []
var current_reward_choices: Array[RelicData] = []
var last_player_card_count: int = 0
var last_dealer_card_count: int = 0
var is_relic_drawer_pinned: bool = false
var is_dealer_sequence_playing: bool = false
var is_stage_clear_sequence_playing: bool = false
var is_reward_screen_open: bool = false
var should_hide_dealer_hole: bool = true
var should_animate_dealer_reveal: bool = false


func _ready() -> void:
	add_child(run_manager)
	_build_ui()
	_update_ui()


func _process(delta: float) -> void:
	_update_chip_physics(delta)


func _build_ui() -> void:
	var background := TextureRect.new()
	background.texture = TABLE_TEXTURE
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	background_shade = ColorRect.new()
	background_shade.color = Color(0.04, 0.00, 0.07, 0.08)
	background_shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background_shade)

	chip_layer = Control.new()
	chip_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chip_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(chip_layer)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 22)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 58)
	margin.add_theme_constant_override("margin_bottom", 14)
	add_child(margin)

	flash_overlay = ColorRect.new()
	flash_overlay.color = Color.WHITE
	flash_overlay.modulate = Color(1.0, 1.0, 1.0, 0.0)
	flash_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(flash_overlay)

	result_burst_label = Label.new()
	result_burst_label.visible = false
	result_burst_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	result_burst_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_burst_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	result_burst_label.add_theme_font_size_override("font_size", 52)
	result_burst_label.add_theme_color_override("font_outline_color", Color(0.04, 0.01, 0.05, 0.95))
	result_burst_label.add_theme_constant_override("outline_size", 10)
	result_burst_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(result_burst_label)

	var root := VBoxContainer.new()
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_theme_constant_override("separation", 6)
	margin.add_child(root)

	root.add_child(_build_header())

	table_area_root = VBoxContainer.new()
	table_area_root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	table_area_root.add_theme_constant_override("separation", 8)
	root.add_child(table_area_root)

	var dealer_panel := _build_hand_panel("Krupier", true)
	table_area_root.add_child(dealer_panel)

	var center_panel := PanelContainer.new()
	center_panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	center_panel.custom_minimum_size = Vector2(620, 44)
	center_panel.rotation_degrees = -0.35
	center_panel.add_theme_stylebox_override("panel", _make_style(Color(0.03, 0.01, 0.06, 0.30), PINK, 1, 8))
	table_area_root.add_child(center_panel)

	message_label = Label.new()
	message_label.text = "Ustaw stawkę i rozdaj."
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message_label.add_theme_font_size_override("font_size", 18)
	message_label.add_theme_color_override("font_color", Color(1.0, 0.94, 0.80))
	message_label.add_theme_color_override("font_outline_color", Color(0.02, 0.00, 0.03, 0.95))
	message_label.add_theme_constant_override("outline_size", 5)
	message_label.custom_minimum_size = Vector2(0, 36)
	center_panel.add_child(message_label)

	var player_panel := _build_hand_panel("Gracz", false)
	table_area_root.add_child(player_panel)

	root.add_child(_build_synergy_panel())
	root.add_child(_build_controls())
	add_child(_build_relic_drawer())
	add_child(_build_reward_overlay())


func _build_header() -> Control:
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 12)

	var title_panel := PanelContainer.new()
	title_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_panel.add_theme_stylebox_override("panel", _make_style(Color(0.02, 0.00, 0.04, 0.18), Color(1.0, 1.0, 1.0, 0.0), 0, 8))
	header.add_child(title_panel)

	var title_box := VBoxContainer.new()
	title_box.add_theme_constant_override("separation", 2)
	title_panel.add_child(title_box)

	var title := Label.new()
	title.text = "Dług wobec Kasyna"
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_outline_color", Color(0.02, 0.00, 0.03, 0.95))
	title.add_theme_constant_override("outline_size", 6)
	title_box.add_child(title)

	stage_label = Label.new()
	stage_label.add_theme_font_size_override("font_size", 12)
	title_box.add_child(stage_label)

	var money_card := _create_stat_card("KASA", GOLD, -1.0)
	money_label = money_card.get_node("Box/Value") as Label
	header.add_child(money_card)

	var hands_card := _create_stat_card("ROZDANIA", CYAN, 0.8)
	hands_label = hands_card.get_node("Box/Value") as Label
	header.add_child(hands_card)

	var debt_card := _create_stat_card("DŁUG", PINK, -0.6)
	debt_label = debt_card.get_node("Box/Value") as Label
	header.add_child(debt_card)

	var combo_card := _create_stat_card("COMBO", Color(1.0, 0.43, 0.95), 1.0)
	combo_label = combo_card.get_node("Box/Value") as Label
	header.add_child(combo_card)

	return header


func _create_stat_card(caption: String, accent_color: Color, tilt: float) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(104, 52)
	panel.rotation_degrees = tilt
	panel.add_theme_stylebox_override("panel", _make_style(Color(0.02, 0.01, 0.04, 0.50), accent_color, 1, 8))

	var box := VBoxContainer.new()
	box.name = "Box"
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(box)

	var accent := ColorRect.new()
	accent.custom_minimum_size = Vector2(0, 3)
	accent.color = accent_color
	box.add_child(accent)

	var caption_label := Label.new()
	caption_label.text = caption
	caption_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption_label.add_theme_font_size_override("font_size", 11)
	caption_label.add_theme_color_override("font_color", Color(0.88, 0.94, 1.0, 0.90))
	box.add_child(caption_label)

	var value_label := Label.new()
	value_label.name = "Value"
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	value_label.add_theme_font_size_override("font_size", 22)
	value_label.add_theme_color_override("font_color", accent_color)
	value_label.add_theme_color_override("font_outline_color", Color(0.02, 0.00, 0.03, 0.95))
	value_label.add_theme_constant_override("outline_size", 5)
	box.add_child(value_label)

	return panel


func _build_hand_panel(title: String, is_dealer: bool) -> Control:
	var panel := PanelContainer.new()
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _make_style(Color(0.0, 0.0, 0.0, 0.0), Color(1.0, 1.0, 1.0, 0.0), 0, 8))

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	panel.add_child(box)

	var top_row := HBoxContainer.new()
	top_row.add_theme_constant_override("separation", 6)
	box.add_child(top_row)

	var name_label := Label.new()
	name_label.text = title.to_upper()
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.add_theme_font_size_override("font_size", 17)
	name_label.add_theme_color_override("font_color", Color(0.93, 1.0, 0.97))
	name_label.add_theme_color_override("font_outline_color", Color(0.02, 0.00, 0.03, 0.95))
	name_label.add_theme_constant_override("outline_size", 5)
	top_row.add_child(name_label)

	var score_badge := PanelContainer.new()
	score_badge.custom_minimum_size = Vector2(128, 58)
	score_badge.rotation_degrees = -1.2 if is_dealer else 1.2
	score_badge.add_theme_stylebox_override("panel", _make_style(Color(0.03, 0.00, 0.05, 0.58), GOLD if not is_dealer else CYAN, 1, 8))
	top_row.add_child(score_badge)

	var score_box := VBoxContainer.new()
	score_box.alignment = BoxContainer.ALIGNMENT_CENTER
	score_box.add_theme_constant_override("separation", -2)
	score_badge.add_child(score_box)

	var score_caption := Label.new()
	score_caption.text = "PUNKTY"
	score_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_caption.add_theme_font_size_override("font_size", 10)
	score_caption.add_theme_color_override("font_color", CYAN if is_dealer else GOLD)
	score_box.add_child(score_caption)

	var score_label := Label.new()
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_label.add_theme_font_size_override("font_size", 38)
	score_label.add_theme_color_override("font_color", Color(1.0, 0.97, 0.84))
	score_label.add_theme_color_override("font_outline_color", Color(0.03, 0.00, 0.05, 0.95))
	score_label.add_theme_constant_override("outline_size", 7)
	score_box.add_child(score_label)

	var cards_row := HBoxContainer.new()
	cards_row.alignment = BoxContainer.ALIGNMENT_CENTER
	cards_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cards_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	cards_row.add_theme_constant_override("separation", 8)
	box.add_child(cards_row)

	if is_dealer:
		dealer_score_label = score_label
		dealer_cards_row = cards_row
	else:
		player_score_label = score_label
		player_cards_row = cards_row

	return panel


func _build_reward_panel() -> Control:
	reward_panel = PanelContainer.new()
	reward_panel.add_theme_stylebox_override("panel", _make_style(Color(0.08, 0.03, 0.12, 0.94), Color(0.98, 0.72, 0.24), 2, 8))

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	reward_panel.add_child(box)

	var title := Label.new()
	title.text = "Wybierz relikt"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 16)
	box.add_child(title)

	var choices_row := HBoxContainer.new()
	choices_row.alignment = BoxContainer.ALIGNMENT_CENTER
	choices_row.add_theme_constant_override("separation", 8)
	box.add_child(choices_row)

	for index: int in range(3):
		var button := _create_relic_button()
		button.pressed.connect(_on_reward_pressed.bind(index))
		reward_buttons.append(button)
		choices_row.add_child(button)

	return reward_panel


func _build_reward_overlay() -> Control:
	reward_overlay = Control.new()
	reward_overlay.visible = false
	reward_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	reward_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)

	var dim := ColorRect.new()
	dim.color = Color(0.02, 0.00, 0.04, 0.72)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	reward_overlay.add_child(dim)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 80)
	margin.add_theme_constant_override("margin_top", 72)
	margin.add_theme_constant_override("margin_right", 80)
	margin.add_theme_constant_override("margin_bottom", 72)
	reward_overlay.add_child(margin)

	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 22)
	margin.add_child(box)

	var title := Label.new()
	title.text = "WYBIERZ RELIKT"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 42)
	title.add_theme_color_override("font_color", GOLD)
	title.add_theme_color_override("font_outline_color", INK)
	title.add_theme_constant_override("outline_size", 10)
	box.add_child(title)

	reward_cards_row = HBoxContainer.new()
	reward_cards_row.alignment = BoxContainer.ALIGNMENT_CENTER
	reward_cards_row.add_theme_constant_override("separation", 22)
	box.add_child(reward_cards_row)

	reward_message_label = Label.new()
	reward_message_label.visible = false
	reward_message_label.text = "RELIKT ZDOBYTY"
	reward_message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	reward_message_label.add_theme_font_size_override("font_size", 30)
	reward_message_label.add_theme_color_override("font_color", CYAN)
	reward_message_label.add_theme_color_override("font_outline_color", INK)
	reward_message_label.add_theme_constant_override("outline_size", 8)
	box.add_child(reward_message_label)

	return reward_overlay


func _create_reward_card(relic: RelicData, index: int) -> Button:
	var card := Button.new()
	card.custom_minimum_size = Vector2(250, 340)
	card.disabled = true
	card.focus_mode = Control.FOCUS_NONE
	card.text = ""
	card.set_meta("relic", relic)
	card.set_meta("index", index)
	card.add_theme_stylebox_override("normal", _make_relic_card_style(relic.rarity, 0.92))
	card.add_theme_stylebox_override("hover", _make_relic_card_style(relic.rarity, 1.0))
	card.add_theme_stylebox_override("pressed", _make_relic_card_style(relic.rarity, 0.78))
	card.add_theme_stylebox_override("disabled", _make_relic_card_style(relic.rarity, 0.62))
	card.pressed.connect(_on_reward_card_pressed.bind(card))
	JuiceManager.wire_button(card)

	var content := Control.new()
	content.name = "Content"
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.set_anchors_preset(Control.PRESET_FULL_RECT)
	card.add_child(content)

	var back := _create_relic_card_back(relic)
	back.name = "Back"
	content.add_child(back)

	var front := _create_relic_card_front(relic)
	front.name = "Front"
	front.visible = false
	content.add_child(front)

	return card


func _create_relic_card_back(relic: RelicData) -> Control:
	var back := PanelContainer.new()
	back.set_anchors_preset(Control.PRESET_FULL_RECT)
	back.add_theme_stylebox_override("panel", _make_style(Color(0.05, 0.01, 0.08, 0.96), JuiceManager.get_rarity_color(relic.rarity), 2, 8))

	var label := Label.new()
	label.text = "?"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 96)
	label.add_theme_color_override("font_color", JuiceManager.get_rarity_color(relic.rarity))
	label.add_theme_color_override("font_outline_color", INK)
	label.add_theme_constant_override("outline_size", 12)
	back.add_child(label)

	return back


func _create_relic_card_front(relic: RelicData) -> Control:
	var front := MarginContainer.new()
	front.set_anchors_preset(Control.PRESET_FULL_RECT)
	front.add_theme_constant_override("margin_left", 16)
	front.add_theme_constant_override("margin_top", 16)
	front.add_theme_constant_override("margin_right", 16)
	front.add_theme_constant_override("margin_bottom", 16)

	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 12)
	front.add_child(box)

	var rarity := Label.new()
	rarity.text = relic.get_rarity_label()
	rarity.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rarity.add_theme_font_size_override("font_size", 14)
	rarity.add_theme_color_override("font_color", JuiceManager.get_rarity_color(relic.rarity))
	rarity.add_theme_color_override("font_outline_color", INK)
	rarity.add_theme_constant_override("outline_size", 4)
	box.add_child(rarity)

	var name_label := Label.new()
	name_label.text = relic.display_name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_label.add_theme_font_size_override("font_size", 25)
	name_label.add_theme_color_override("font_color", Color(1.0, 0.94, 0.76))
	name_label.add_theme_color_override("font_outline_color", INK)
	name_label.add_theme_constant_override("outline_size", 6)
	box.add_child(name_label)

	var divider := ColorRect.new()
	divider.color = JuiceManager.get_rarity_color(relic.rarity)
	divider.custom_minimum_size = Vector2(0, 3)
	box.add_child(divider)

	var description_label := Label.new()
	description_label.text = relic.description
	description_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description_label.add_theme_font_size_override("font_size", 17)
	description_label.add_theme_color_override("font_color", Color(0.92, 0.88, 0.78))
	box.add_child(description_label)

	var tags_label := Label.new()
	tags_label.text = _format_relic_tags(relic.tags)
	tags_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tags_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tags_label.add_theme_font_size_override("font_size", 12)
	tags_label.add_theme_color_override("font_color", Color(0.70, 0.90, 1.0, 0.74))
	box.add_child(tags_label)

	return front


func _format_relic_tags(tags: Array[String]) -> String:
	var formatted := PackedStringArray()
	for tag: String in tags:
		formatted.append("#%s" % _get_tag_label(tag))

	return " ".join(formatted)


func _get_tag_label(tag: String) -> String:
	match tag:
		"ace":
			return "as"
		"dealer":
			return "krupier"
		"money":
			return "kasa"
		"risk":
			return "ryzyko"
		"blackjack":
			return "blackjack"
		"king":
			return "król"
		"queen":
			return "dama"
		"bust":
			return "przebicie"
		"token":
			return "żeton"
		"target_score":
			return "limit"
		"payout":
			return "wypłata"
		"safety":
			return "bezpieczny"

	return tag


func _make_relic_card_style(rarity: String, alpha: float) -> StyleBoxFlat:
	var color := JuiceManager.get_rarity_color(rarity)
	var style := _make_style(Color(0.05, 0.015, 0.08, alpha), color, _get_rarity_border_width(rarity), 8)
	style.shadow_color = Color(color.r, color.g, color.b, 0.34 * alpha)
	style.shadow_size = int(4 + JuiceManager.get_rarity_intensity(rarity) * 10.0)
	style.shadow_offset = Vector2(0, 0)
	return style


func _get_rarity_border_width(rarity: String) -> int:
	match rarity:
		RelicData.RARITY_RARE:
			return 2
		RelicData.RARITY_EPIC, RelicData.RARITY_LEGENDARY:
			return 3

	return 1


func _build_relic_drawer() -> Control:
	var shell := Control.new()
	shell.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shell.set_anchors_preset(Control.PRESET_FULL_RECT)

	relics_button = _create_small_button("<")
	relics_button.tooltip_text = "Relikty"
	relics_button.custom_minimum_size = Vector2(42, 96)
	relics_button.anchor_left = 1.0
	relics_button.anchor_right = 1.0
	relics_button.anchor_top = 0.44
	relics_button.anchor_bottom = 0.44
	relics_button.offset_left = -42
	relics_button.offset_right = 0
	relics_button.offset_top = -48
	relics_button.offset_bottom = 48
	relics_button.pressed.connect(_on_relics_button_pressed)
	relics_button.mouse_entered.connect(_show_relic_drawer)
	relics_button.mouse_exited.connect(_on_relic_button_mouse_exited)
	shell.add_child(relics_button)

	relic_drawer_panel = PanelContainer.new()
	relic_drawer_panel.visible = false
	relic_drawer_panel.custom_minimum_size = Vector2(RELIC_DRAWER_WIDTH, 280)
	relic_drawer_panel.anchor_left = 1.0
	relic_drawer_panel.anchor_right = 1.0
	relic_drawer_panel.anchor_top = 0.25
	relic_drawer_panel.anchor_bottom = 0.75
	relic_drawer_panel.offset_left = -RELIC_DRAWER_WIDTH - 44.0
	relic_drawer_panel.offset_right = -46.0
	relic_drawer_panel.offset_top = 0.0
	relic_drawer_panel.offset_bottom = 0.0
	relic_drawer_panel.add_theme_stylebox_override("panel", _make_style(Color(0.03, 0.01, 0.05, 0.78), Color(1.0, 1.0, 1.0, 0.0), 0, 8))
	relic_drawer_panel.mouse_entered.connect(_show_relic_drawer)
	relic_drawer_panel.mouse_exited.connect(_on_relic_drawer_mouse_exited)
	shell.add_child(relic_drawer_panel)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	relic_drawer_panel.add_child(box)

	var title := Label.new()
	title.text = "Relikty"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 16)
	box.add_child(title)

	relic_drawer_list = VBoxContainer.new()
	relic_drawer_list.add_theme_constant_override("separation", 6)
	box.add_child(relic_drawer_list)

	return shell


func _build_synergy_panel() -> Control:
	synergy_panel = PanelContainer.new()
	synergy_panel.visible = false
	synergy_panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	synergy_panel.rotation_degrees = -0.25
	synergy_panel.add_theme_stylebox_override("panel", _make_style(Color(0.03, 0.01, 0.05, 0.50), Color(1.0, 0.43, 0.95, 0.55), 1, 8))

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 3)
	synergy_panel.add_child(box)

	var title := Label.new()
	title.text = "AKTYWNE SYNERGIE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 11)
	title.add_theme_color_override("font_color", Color(1.0, 0.76, 1.0))
	title.add_theme_color_override("font_outline_color", INK)
	title.add_theme_constant_override("outline_size", 3)
	box.add_child(title)

	synergy_list = VBoxContainer.new()
	synergy_list.add_theme_constant_override("separation", 2)
	box.add_child(synergy_list)

	return synergy_panel


func _build_controls() -> Control:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	panel.rotation_degrees = 0.25
	panel.add_theme_stylebox_override("panel", _make_style(Color(0.03, 0.01, 0.05, 0.60), CYAN, 1, 8))

	var controls := HBoxContainer.new()
	controls.alignment = BoxContainer.ALIGNMENT_CENTER
	controls.add_theme_constant_override("separation", 14)
	panel.add_child(controls)

	var bet_controls := HBoxContainer.new()
	bet_controls.alignment = BoxContainer.ALIGNMENT_CENTER
	bet_controls.add_theme_constant_override("separation", 6)
	controls.add_child(bet_controls)

	var bet_label := Label.new()
	bet_label.text = "STAWKA"
	bet_label.add_theme_font_size_override("font_size", 16)
	bet_label.add_theme_color_override("font_color", GOLD)
	bet_label.add_theme_color_override("font_outline_color", INK)
	bet_label.add_theme_constant_override("outline_size", 4)
	bet_controls.add_child(bet_label)

	decrease_bet_button = _create_small_button("-5")
	decrease_bet_button.rotation_degrees = -1.0
	decrease_bet_button.pressed.connect(_on_decrease_bet_pressed)
	bet_controls.add_child(decrease_bet_button)

	bet_input = SpinBox.new()
	bet_input.min_value = 1
	bet_input.max_value = run_manager.money
	bet_input.step = 1
	bet_input.value = DEFAULT_BET
	bet_input.custom_minimum_size = Vector2(96, 34)
	bet_input.add_theme_font_size_override("font_size", 16)
	bet_input.add_theme_color_override("font_color", Color(1.0, 0.94, 0.74))
	bet_controls.add_child(bet_input)

	increase_bet_button = _create_small_button("+5")
	increase_bet_button.rotation_degrees = 1.0
	increase_bet_button.pressed.connect(_on_increase_bet_pressed)
	bet_controls.add_child(increase_bet_button)

	max_bet_button = _create_small_button("MAX")
	max_bet_button.rotation_degrees = -0.8
	max_bet_button.pressed.connect(_on_max_bet_pressed)
	bet_controls.add_child(max_bet_button)

	var action_controls := HBoxContainer.new()
	action_controls.alignment = BoxContainer.ALIGNMENT_CENTER
	action_controls.add_theme_constant_override("separation", 8)
	controls.add_child(action_controls)

	deal_button = _create_action_button("ROZDAJ", GOLD, Color(0.20, 0.07, 0.12))
	deal_button.rotation_degrees = -1.0
	deal_button.pressed.connect(_on_deal_pressed)
	action_controls.add_child(deal_button)

	hit_button = _create_action_button("DOBIERZ", CYAN, Color(0.03, 0.12, 0.14))
	hit_button.rotation_degrees = 0.6
	hit_button.pressed.connect(_on_hit_pressed)
	action_controls.add_child(hit_button)

	stand_button = _create_action_button("STÓJ", PINK, Color(0.16, 0.04, 0.13))
	stand_button.rotation_degrees = -0.6
	stand_button.pressed.connect(_on_stand_pressed)
	action_controls.add_child(stand_button)

	retry_button = _create_action_button("OD NOWA", Color(0.94, 0.94, 1.0), Color(0.09, 0.08, 0.12))
	retry_button.rotation_degrees = 1.0
	retry_button.pressed.connect(_on_retry_pressed)
	action_controls.add_child(retry_button)

	return panel


func _create_action_button(text: String, accent_color: Color = GOLD, bg_color: Color = Color(0.19, 0.05, 0.18)) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(118, 44)
	button.add_theme_font_size_override("font_size", 16)
	button.add_theme_color_override("font_color", accent_color)
	button.add_theme_color_override("font_outline_color", INK)
	button.add_theme_constant_override("outline_size", 3)
	_apply_button_style(button, accent_color, bg_color)
	_wire_button_motion(button)
	return button


func _create_small_button(text: String) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(58, 34)
	button.add_theme_font_size_override("font_size", 13)
	button.add_theme_color_override("font_color", CYAN)
	button.add_theme_color_override("font_outline_color", INK)
	button.add_theme_constant_override("outline_size", 2)
	_apply_button_style(button, CYAN, Color(0.07, 0.04, 0.14))
	_wire_button_motion(button)
	return button


func _apply_button_style(button: Button, border_color: Color, bg_color: Color) -> void:
	button.add_theme_stylebox_override("normal", _make_style(bg_color, Color(1.0, 1.0, 1.0, 0.0), 0, 8))
	button.add_theme_stylebox_override("hover", _make_style(bg_color.lightened(0.10), border_color.lightened(0.12), 1, 8))
	button.add_theme_stylebox_override("pressed", _make_style(bg_color.darkened(0.08), Color(1.0, 1.0, 1.0, 0.0), 0, 8))
	button.add_theme_stylebox_override("disabled", _make_style(Color(0.08, 0.07, 0.08, 0.34), Color(1.0, 1.0, 1.0, 0.0), 0, 8))


func _create_relic_button() -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(220, 56)
	button.add_theme_font_size_override("font_size", 13)
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_apply_button_style(button, Color(0.98, 0.72, 0.24), Color(0.14, 0.04, 0.16))
	_wire_button_motion(button)
	return button


func _wire_button_motion(button: Button) -> void:
	JuiceManager.wire_button(button)


func _update_chip_physics(delta: float) -> void:
	if active_chips.is_empty():
		return

	for index: int in range(active_chips.size() - 1, -1, -1):
		var chip := active_chips[index]
		if not is_instance_valid(chip):
			active_chips.remove_at(index)
			continue

		var delay := float(chip.get_meta("delay", 0.0))
		if delay > 0.0:
			delay = maxf(delay - delta, 0.0)
			chip.set_meta("delay", delay)
			continue

		if chip.modulate.a < 1.0:
			chip.modulate.a = minf(chip.modulate.a + delta * 10.0, 1.0)

		if chip.scale.x < 1.0:
			var next_scale := minf(chip.scale.x + delta * 4.8, 1.0)
			chip.scale = Vector2(next_scale, next_scale)

		var velocity: Vector2 = chip.get_meta("velocity", Vector2.ZERO)
		var home: Vector2 = chip.get_meta("home", chip.position)
		var to_home := home - chip.position
		velocity += to_home * CHIP_ATTRACTION * delta
		velocity *= pow(CHIP_FRICTION, delta)

		if velocity.length() < 5.0 and to_home.length() < 5.0:
			velocity = Vector2.ZERO
			chip.position = chip.position.lerp(home, minf(delta * 6.0, 1.0))

		chip.position += velocity * delta
		chip.rotation_degrees += float(chip.get_meta("spin", 0.0)) * delta * clampf(velocity.length() / 520.0, 0.0, 1.0)
		chip.set_meta("velocity", velocity)

	_resolve_chip_collisions()


func _resolve_chip_collisions() -> void:
	for first_index: int in range(active_chips.size()):
		var first_chip := active_chips[first_index]
		if not is_instance_valid(first_chip):
			continue

		for second_index: int in range(first_index + 1, active_chips.size()):
			var second_chip := active_chips[second_index]
			if not is_instance_valid(second_chip):
				continue

			var first_center := first_chip.position + Vector2(CHIP_RADIUS, CHIP_RADIUS)
			var second_center := second_chip.position + Vector2(CHIP_RADIUS, CHIP_RADIUS)
			var delta_position := first_center - second_center
			var distance := delta_position.length()
			var minimum_distance := CHIP_COLLISION_RADIUS * 2.0
			if distance >= minimum_distance:
				continue

			var normal := Vector2.RIGHT.rotated(randf_range(0.0, TAU)) if distance <= 0.01 else delta_position / distance
			var overlap := minimum_distance - distance
			first_chip.position += normal * overlap * 0.5
			second_chip.position -= normal * overlap * 0.5

			var first_velocity: Vector2 = first_chip.get_meta("velocity", Vector2.ZERO)
			var second_velocity: Vector2 = second_chip.get_meta("velocity", Vector2.ZERO)
			var relative_velocity := first_velocity - second_velocity
			var impact := relative_velocity.dot(normal)
			if impact < 0.0:
				var impulse := normal * impact * CHIP_BOUNCE
				first_velocity -= impulse
				second_velocity += impulse
				first_chip.set_meta("velocity", first_velocity)
				second_chip.set_meta("velocity", second_velocity)


func _throw_bet_chips(bet: int) -> void:
	_clear_bet_chips()

	var viewport_size := get_viewport_rect().size
	var chip_count := clampi(int(ceil(float(bet) / 5.0)), 1, 18)
	var target_center := Vector2(viewport_size.x * 0.5, viewport_size.y * 0.52)
	var start_center := Vector2(viewport_size.x * 0.5, viewport_size.y + 44.0)

	for index: int in range(chip_count):
		var chip := _create_chip(index)
		var delay := index * 0.035
		var start_position := start_center + Vector2(randf_range(-80.0, 80.0), randf_range(0.0, 34.0))
		var target_position := target_center + Vector2((index - chip_count * 0.5) * 10.0 + randf_range(-26.0, 26.0), randf_range(-24.0, 24.0))
		var launch_velocity := (target_position - start_position) * randf_range(3.6, 4.6) + Vector2(randf_range(-150.0, 150.0), randf_range(-70.0, 30.0))
		chip.position = start_position
		chip.rotation_degrees = randf_range(-24.0, 24.0)
		chip.scale = Vector2(0.45, 0.45)
		chip.modulate = Color(1.0, 1.0, 1.0, 0.0)
		chip.set_meta("velocity", launch_velocity)
		chip.set_meta("home", target_position)
		chip.set_meta("delay", delay)
		chip.set_meta("spin", randf_range(-260.0, 260.0))
		chip.set_meta("is_chip", true)
		chip_layer.add_child(chip)
		active_chips.append(chip)

	var pot_label := Label.new()
	pot_label.name = "PotLabel"
	pot_label.text = "$%d" % bet
	pot_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pot_label.add_theme_font_size_override("font_size", 22)
	pot_label.add_theme_color_override("font_color", GOLD)
	pot_label.add_theme_color_override("font_outline_color", INK)
	pot_label.add_theme_constant_override("outline_size", 6)
	pot_label.position = target_center + Vector2(-44.0, 28.0)
	pot_label.size = Vector2(88.0, 32.0)
	pot_label.scale = Vector2(0.72, 0.72)
	pot_label.modulate = Color(1.0, 1.0, 1.0, 0.0)
	chip_layer.add_child(pot_label)

	var label_tween := create_tween()
	label_tween.tween_interval(0.34)
	label_tween.tween_property(pot_label, "modulate:a", 1.0, 0.08)
	label_tween.parallel().tween_property(pot_label, "scale", Vector2.ONE, 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _collect_bet_chips(result: String) -> void:
	if chip_layer.get_child_count() == 0:
		return

	active_chips.clear()
	var viewport_size := get_viewport_rect().size
	var exit_position := Vector2(viewport_size.x * 0.5, -60.0)
	if result == BlackjackResult.PLAYER_BUST or result == BlackjackResult.DEALER_WIN or result == BlackjackResult.DEALER_BLACKJACK:
		exit_position = Vector2(viewport_size.x - 80.0, viewport_size.y * 0.25)
	elif result == BlackjackResult.PLAYER_WIN or result == BlackjackResult.PLAYER_BLACKJACK or result == BlackjackResult.DEALER_BUST:
		exit_position = Vector2(90.0, viewport_size.y - 78.0)

	for child: Control in chip_layer.get_children():
		var delay := 0.42 + randf_range(0.0, 0.08)
		var tween := create_tween()
		tween.set_parallel(true)
		tween.tween_property(child, "position", exit_position + Vector2(randf_range(-32.0, 32.0), randf_range(-18.0, 18.0)), 0.24).set_delay(delay).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		tween.tween_property(child, "scale", Vector2(0.55, 0.55), 0.20).set_delay(delay)
		tween.tween_property(child, "modulate:a", 0.0, 0.18).set_delay(delay)
		tween.chain().tween_callback(child.queue_free)


func _clear_bet_chips() -> void:
	if not is_instance_valid(chip_layer):
		return

	active_chips.clear()
	_clear_children(chip_layer)


func _create_chip(index: int) -> Control:
	var chip := Control.new()
	chip.custom_minimum_size = CHIP_SIZE
	chip.size = CHIP_SIZE
	chip.pivot_offset = CHIP_SIZE * 0.5
	chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var chip_color := _get_chip_color(index)

	var shadow := PanelContainer.new()
	shadow.position = Vector2(5, 7)
	shadow.size = Vector2(38, 34)
	shadow.add_theme_stylebox_override("panel", _make_style(Color(0.0, 0.0, 0.0, 0.42), Color(1.0, 1.0, 1.0, 0.0), 0, 20))
	chip.add_child(shadow)

	var side := PanelContainer.new()
	side.position = Vector2(1, 4)
	side.size = Vector2(40, 38)
	side.add_theme_stylebox_override("panel", _make_style(chip_color.darkened(0.35), Color(0.03, 0.0, 0.04, 0.70), 1, 20))
	chip.add_child(side)

	var outer := PanelContainer.new()
	outer.size = Vector2(40, 40)
	outer.add_theme_stylebox_override("panel", _make_style(chip_color, Color(1.0, 0.94, 0.72), 2, 20))
	chip.add_child(outer)

	for notch_index: int in range(8):
		var notch := ColorRect.new()
		notch.color = Color(1.0, 0.94, 0.72, 0.95)
		notch.size = Vector2(4, 9)
		notch.position = Vector2(18, 2)
		notch.pivot_offset = Vector2(2, 19)
		notch.rotation_degrees = notch_index * 45.0
		chip.add_child(notch)

	var inner_ring := PanelContainer.new()
	inner_ring.position = Vector2(7, 7)
	inner_ring.size = Vector2(26, 26)
	inner_ring.add_theme_stylebox_override("panel", _make_style(chip_color.lightened(0.18), Color(0.03, 0.0, 0.04, 0.70), 1, 14))
	chip.add_child(inner_ring)

	var inner := PanelContainer.new()
	inner.position = Vector2(11, 11)
	inner.size = Vector2(18, 18)
	inner.add_theme_stylebox_override("panel", _make_style(Color(1.0, 0.92, 0.68, 0.96), INK, 1, 10))
	chip.add_child(inner)

	var mark := Label.new()
	mark.text = _get_chip_label(index)
	mark.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mark.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	mark.add_theme_font_size_override("font_size", 11)
	mark.add_theme_color_override("font_color", INK)
	mark.add_theme_color_override("font_outline_color", Color(1.0, 0.92, 0.68, 0.55))
	mark.add_theme_constant_override("outline_size", 1)
	mark.set_anchors_preset(Control.PRESET_FULL_RECT)
	chip.add_child(mark)

	var shine := ColorRect.new()
	shine.color = Color(1.0, 1.0, 1.0, 0.30)
	shine.position = Vector2(12, 7)
	shine.size = Vector2(14, 4)
	shine.rotation_degrees = -22.0
	chip.add_child(shine)

	return chip


func _get_chip_color(index: int) -> Color:
	match index % 4:
		0:
			return PINK
		1:
			return CYAN
		2:
			return GOLD

	return Color(0.78, 0.38, 1.0)


func _get_chip_label(index: int) -> String:
	match index % 5:
		0:
			return "$1"
		1:
			return "$5"
		2:
			return "$10"
		3:
			return "$25"

	return "$50"


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_D:
				if not deal_button.disabled:
					_on_deal_pressed()
			KEY_H:
				if not hit_button.disabled:
					_on_hit_pressed()
			KEY_S:
				if not stand_button.disabled:
					_on_stand_pressed()
			KEY_PLUS, KEY_EQUAL:
				if not increase_bet_button.disabled:
					_change_bet(5)
			KEY_MINUS:
				if not decrease_bet_button.disabled:
					_change_bet(-5)
			KEY_M:
				if not max_bet_button.disabled:
					_on_max_bet_pressed()


func _on_decrease_bet_pressed() -> void:
	_change_bet(-5)


func _on_increase_bet_pressed() -> void:
	_change_bet(5)


func _on_max_bet_pressed() -> void:
	bet_input.value = max(1, run_manager.money)
	JuiceManager.pulse_label(bet_input, 1.08, 0.16)


func _change_bet(amount: int) -> void:
	var next_bet := clampi(int(bet_input.value) + amount, 1, max(1, run_manager.money))
	bet_input.value = next_bet
	JuiceManager.pulse_label(bet_input, 1.08, 0.16)


func _on_deal_pressed() -> void:
	var bet := int(bet_input.value)

	if not run_manager.start_hand(bet):
		message_label.text = "Nie możesz zagrać z taką stawką."
		_update_ui()
		return

	_throw_bet_chips(bet)
	engine.start_round(bet)
	should_hide_dealer_hole = true
	message_label.text = "Twój ruch."

	var opening_result := engine.resolve_round() if _has_opening_blackjack() else ""
	if opening_result != "":
		should_hide_dealer_hole = false
		_apply_round_result(opening_result)

	_update_ui()


func _on_hit_pressed() -> void:
	var result := engine.player_hit()

	if result != "":
		should_hide_dealer_hole = false
		_apply_round_result(result)
	else:
		message_label.text = "Karta dobrana. Dobierz albo stój."

	_update_ui()


func _on_stand_pressed() -> void:
	if not engine.is_round_active or is_dealer_sequence_playing:
		return

	is_dealer_sequence_playing = true
	should_hide_dealer_hole = false
	should_animate_dealer_reveal = true
	message_label.text = "Krupier odkrywa kartę."
	_update_ui()
	await get_tree().create_timer(0.42).timeout

	while engine.is_round_active and engine.dealer_hand.get_value(engine.rules) < engine.rules.dealer_stand_score:
		engine.dealer_hand.add_card(engine.deck.draw_card())
		message_label.text = "Krupier dobiera."
		_update_ui()
		await get_tree().create_timer(0.38).timeout

	var result := engine.resolve_round()
	is_dealer_sequence_playing = false
	_apply_round_result(result)
	_update_ui()


func _on_reward_pressed(index: int) -> void:
	if index < 0 or index >= current_reward_choices.size():
		return

	var relic := current_reward_choices[index]
	run_manager.add_relic(relic, engine.rules)
	run_manager.advance_stage()
	run_manager.rebuild_effective_state(engine.rules)
	engine.reset_round()
	_clear_bet_chips()
	should_hide_dealer_hole = true
	should_animate_dealer_reveal = false
	current_reward_choices.clear()
	message_label.text = "%s zdobyty. Etap %d. Dług wzrósł." % [relic.display_name, run_manager.stage]
	_update_ui()


func _on_reward_card_pressed(card: Button) -> void:
	if not is_reward_screen_open or not is_instance_valid(card):
		return
	if card.disabled:
		return

	var relic := card.get_meta("relic") as RelicData
	if relic == null:
		return

	is_reward_screen_open = false
	for view: Control in reward_card_views:
		if view is Button:
			(view as Button).disabled = true

	var dismissed: Array[Control] = []
	for view: Control in reward_card_views:
		if view != card:
			dismissed.append(view)

	JuiceManager.play_relic_selected(self, card, dismissed, reward_message_label)
	await get_tree().create_timer(0.52).timeout

	run_manager.add_relic(relic, engine.rules)
	await _play_new_synergy_feedback()
	run_manager.advance_stage()
	run_manager.rebuild_effective_state(engine.rules)
	engine.reset_round()
	_clear_bet_chips()
	should_hide_dealer_hole = true
	should_animate_dealer_reveal = false
	current_reward_choices.clear()
	reward_card_views.clear()
	reward_overlay.visible = false
	reward_message_label.visible = false
	message_label.text = "%s zdobyty. Etap %d." % [relic.display_name, run_manager.stage]
	_update_ui()


func _on_retry_pressed() -> void:
	run_manager.reset_run()
	engine = BlackjackEngine.new()
	_clear_bet_chips()
	current_reward_choices.clear()
	reward_card_views.clear()
	is_relic_drawer_pinned = false
	is_dealer_sequence_playing = false
	is_stage_clear_sequence_playing = false
	is_reward_screen_open = false
	should_hide_dealer_hole = true
	should_animate_dealer_reveal = false
	if is_instance_valid(reward_overlay):
		reward_overlay.visible = false
	if is_instance_valid(background_shade):
		background_shade.color = Color(0.04, 0.00, 0.07, 0.08)
	message_label.text = "Nowy run. Ustaw stawkę i rozdaj."
	_update_ui()


func _has_opening_blackjack() -> bool:
	return engine.player_hand.is_blackjack(engine.rules) or engine.dealer_hand.is_blackjack(engine.rules)


func _apply_round_result(result: String) -> void:
	var money_before_payout := run_manager.money
	var combo_before := run_manager.combo_count
	var payout := run_manager.apply_result(result, engine.current_bet, engine.rules)
	var money_delta := run_manager.money - money_before_payout
	message_label.text = "%s Wypłata: $%d. Kasa: $%d -> $%d." % [
		_get_result_text(result),
		payout,
		money_before_payout,
		run_manager.money,
	]

	var stage_cleared := run_manager.is_stage_success()
	var game_lost := run_manager.is_game_over()
	if stage_cleared:
		message_label.text = "DŁUG SPŁACONY"
	elif game_lost:
		message_label.text = "KASYNO WYGRYWA"

	_spawn_money_popup(money_delta)
	_play_combo_feedback(combo_before)
	_pulse_message()
	_play_result_feedback(result, payout)
	_collect_bet_chips(result)
	if stage_cleared:
		_start_stage_clear_feedback()
	elif game_lost:
		_start_game_over_feedback()


func _spawn_money_popup(delta: int) -> void:
	JuiceManager.play_money_popup(self, money_label, delta)


func _play_combo_feedback(combo_before: int) -> void:
	if run_manager.last_combo_delta > 0:
		if run_manager.combo_count >= 2:
			var text := "COMBO x%d" % run_manager.combo_count
			var position := combo_label.get_global_rect().get_center() if is_instance_valid(combo_label) else get_viewport_rect().size * 0.5
			JuiceManager.play_combo_popup(self, text, position)
			JuiceManager.pulse_label(combo_label, 1.22, 0.22)
		elif combo_before == 0:
			JuiceManager.pulse_label(combo_label, 1.10, 0.16)
	elif run_manager.last_combo_was_reset and is_instance_valid(combo_label):
		JuiceShake.shake_node(combo_label, 6.0, 0.18)


func _start_stage_clear_feedback() -> void:
	if is_stage_clear_sequence_playing:
		return

	is_stage_clear_sequence_playing = true
	JuiceManager.play_stage_success(self, result_burst_label, money_label, debt_label, flash_overlay)
	JuiceTweenFactory.delayed_call(self, 0.82, Callable(self, "_finish_stage_clear_feedback"))


func _finish_stage_clear_feedback() -> void:
	is_stage_clear_sequence_playing = false
	current_reward_choices = RelicLibrary.get_reward_choices(3, run_manager.get_owned_relic_ids())
	_show_reward_screen()
	_update_ui()


func _show_reward_screen() -> void:
	_clear_children(reward_cards_row)
	reward_card_views.clear()
	reward_message_label.visible = false
	reward_overlay.visible = true
	is_reward_screen_open = true

	for index: int in range(current_reward_choices.size()):
		var card := _create_reward_card(current_reward_choices[index], index)
		card.modulate.a = 0.0
		card.scale = Vector2(0.88, 0.88)
		card.rotation_degrees = randf_range(-2.0, 2.0)
		reward_cards_row.add_child(card)
		reward_card_views.append(card)

	JuiceManager.play_reward_anticipation(reward_overlay)
	_reveal_reward_cards()


func _reveal_reward_cards() -> void:
	for index: int in range(reward_card_views.size()):
		if not is_reward_screen_open:
			return

		var card := reward_card_views[index] as Button
		if not is_instance_valid(card):
			continue

		await get_tree().create_timer(0.22 + index * 0.16).timeout
		if not is_reward_screen_open:
			return

		var relic := card.get_meta("relic") as RelicData
		_reveal_reward_card(card, relic)


func _reveal_reward_card(card: Button, relic: RelicData) -> void:
	if relic == null:
		return

	var back := card.get_node_or_null("Content/Back") as Control
	var front := card.get_node_or_null("Content/Front") as Control
	if is_instance_valid(back):
		back.visible = false
	if is_instance_valid(front):
		front.visible = true

	card.disabled = false
	JuiceManager.play_relic_rarity_reveal(self, card, relic.rarity, flash_overlay)


func _start_game_over_feedback() -> void:
	JuiceManager.play_failure(self, table_area_root, result_burst_label, message_label, background_shade)


func _play_new_synergy_feedback() -> void:
	if run_manager.newly_discovered_synergies.is_empty():
		return

	for synergy: SynergyData in run_manager.newly_discovered_synergies:
		var title := "SYNERGIA ODKRYTA: %s" % synergy.display_name.to_upper()
		reward_message_label.text = title
		reward_message_label.visible = true
		JuiceManager.show_result_banner(result_burst_label, title, Color(1.0, 0.43, 0.95), 0.86)
		JuiceManager.play_combo_popup(self, synergy.description, reward_message_label.get_global_rect().get_center() + Vector2(0.0, 42.0))
		JuiceManager.pulse_label(reward_message_label, 1.14, 0.24)
		JuiceShake.shake_node(reward_message_label, 4.0, 0.18)
		await get_tree().create_timer(0.72).timeout


func _update_ui() -> void:
	var player_value := engine.player_hand.get_value(engine.rules) if not engine.player_hand.cards.is_empty() else 0
	var dealer_value := engine.dealer_hand.get_value(engine.rules) if not engine.dealer_hand.cards.is_empty() else 0

	stage_label.text = "Etap %d | Żetony %d" % [run_manager.stage, run_manager.tokens]
	money_label.text = "$%d" % run_manager.money
	hands_label.text = "%d" % run_manager.hands_left
	debt_label.text = "$%d" % run_manager.debt_target
	combo_label.text = run_manager.get_combo_display_text()

	player_score_label.text = "%d" % player_value if player_value > 0 else "-"
	dealer_score_label.text = _get_dealer_score_text(dealer_value)

	_render_hand_cards(player_cards_row, engine.player_hand, false, last_player_card_count)
	_render_hand_cards(dealer_cards_row, engine.dealer_hand, should_hide_dealer_hole, last_dealer_card_count, should_animate_dealer_reveal)
	should_animate_dealer_reveal = false
	last_player_card_count = engine.player_hand.cards.size()
	last_dealer_card_count = engine.dealer_hand.cards.size()

	bet_input.max_value = max(1, run_manager.money)
	if bet_input.value > bet_input.max_value:
		bet_input.value = bet_input.max_value

	var stage_ready_to_advance := run_manager.is_stage_success() and not engine.is_round_active
	var game_over := run_manager.is_game_over() and not engine.is_round_active

	deal_button.disabled = engine.is_round_active or is_dealer_sequence_playing or stage_ready_to_advance or game_over or not run_manager.can_play_hand()
	hit_button.disabled = not engine.is_round_active or is_dealer_sequence_playing
	stand_button.disabled = not engine.is_round_active or is_dealer_sequence_playing
	retry_button.disabled = not game_over
	retry_button.visible = game_over
	decrease_bet_button.disabled = engine.is_round_active or is_dealer_sequence_playing or game_over or stage_ready_to_advance
	increase_bet_button.disabled = engine.is_round_active or is_dealer_sequence_playing or game_over or stage_ready_to_advance
	max_bet_button.disabled = engine.is_round_active or is_dealer_sequence_playing or game_over or stage_ready_to_advance
	if is_instance_valid(reward_panel):
		reward_panel.visible = false
	relics_button.text = _get_relics_text()
	_update_reward_buttons()
	_update_relic_drawer()
	_update_synergy_panel()
	bet_input.editable = not engine.is_round_active and not is_dealer_sequence_playing


func _get_dealer_score_text(dealer_value: int) -> String:
	if engine.dealer_hand.cards.is_empty():
		return "-"
	if should_hide_dealer_hole and engine.dealer_hand.cards.size() > 1:
		return "?"

	return "%d" % dealer_value


func _update_reward_buttons() -> void:
	for index: int in range(reward_buttons.size()):
		var button := reward_buttons[index]
		var has_choice := index < current_reward_choices.size()
		button.visible = has_choice
		button.disabled = not has_choice

		if has_choice:
			button.text = current_reward_choices[index].get_reward_text()


func _get_relics_text() -> String:
	if run_manager.relics.is_empty():
		return "< 0"

	return "< %d" % run_manager.relics.size()


func _update_relic_drawer() -> void:
	_clear_children(relic_drawer_list)

	if run_manager.relics.is_empty():
		var empty_label := Label.new()
		empty_label.text = "Brak reliktów."
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_label.add_theme_font_size_override("font_size", 13)
		relic_drawer_list.add_child(empty_label)
		return

	for relic: RelicData in run_manager.relics:
		relic_drawer_list.add_child(_create_owned_relic_view(relic))


func _update_synergy_panel() -> void:
	if not is_instance_valid(synergy_panel) or not is_instance_valid(synergy_list):
		return

	_clear_children(synergy_list)
	synergy_panel.visible = not run_manager.active_synergies.is_empty()
	if run_manager.active_synergies.is_empty():
		return

	for synergy: SynergyData in run_manager.active_synergies:
		var label := Label.new()
		label.text = "%s  POZ. %d" % [synergy.display_name.to_upper(), synergy.level]
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 13)
		label.add_theme_color_override("font_color", Color(1.0, 0.94, 0.78))
		label.add_theme_color_override("font_outline_color", INK)
		label.add_theme_constant_override("outline_size", 3)
		synergy_list.add_child(label)


func _create_owned_relic_view(relic: RelicData) -> Control:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _make_style(Color(0.08, 0.03, 0.12, 0.68), Color(1.0, 1.0, 1.0, 0.0), 0, 8))

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 2)
	panel.add_child(box)

	var name_label := Label.new()
	name_label.text = relic.display_name
	name_label.add_theme_font_size_override("font_size", 14)
	box.add_child(name_label)

	var description_label := Label.new()
	description_label.text = relic.description
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description_label.add_theme_font_size_override("font_size", 12)
	description_label.modulate = Color(0.90, 0.82, 0.66)
	box.add_child(description_label)

	return panel


func _on_relics_button_pressed() -> void:
	is_relic_drawer_pinned = not is_relic_drawer_pinned
	relic_drawer_panel.visible = is_relic_drawer_pinned or not relic_drawer_panel.visible


func _show_relic_drawer() -> void:
	if relic_drawer_panel.visible:
		return

	relic_drawer_panel.visible = true
	relic_drawer_panel.position.x = 18.0
	relic_drawer_panel.modulate = Color(1.0, 1.0, 1.0, 0.0)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(relic_drawer_panel, "position:x", 0.0, 0.14).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(relic_drawer_panel, "modulate:a", 1.0, 0.10)


func _on_relic_button_mouse_exited() -> void:
	call_deferred("_hide_relic_drawer_if_unhovered")


func _on_relic_drawer_mouse_exited() -> void:
	call_deferred("_hide_relic_drawer_if_unhovered")


func _hide_relic_drawer_if_unhovered() -> void:
	if is_relic_drawer_pinned:
		return

	var mouse_position := get_global_mouse_position()
	var is_over_button := relics_button.get_global_rect().has_point(mouse_position)
	var is_over_drawer := relic_drawer_panel.get_global_rect().has_point(mouse_position)
	relic_drawer_panel.visible = is_over_button or is_over_drawer


func _render_hand_cards(row: HBoxContainer, hand: Hand, hide_hole_card: bool, previous_card_count: int, animate_hole_reveal: bool = false) -> void:
	_clear_children(row)

	if hand.cards.is_empty():
		row.add_child(_create_empty_slot())
		return

	for index: int in range(hand.cards.size()):
		var hidden := hide_hole_card and index == 1
		var should_animate := index >= previous_card_count or (animate_hole_reveal and index == 1)
		row.add_child(_create_card_view(hand.cards[index], hidden, should_animate, index * 0.07))


func _create_empty_slot() -> Control:
	var slot := PanelContainer.new()
	slot.custom_minimum_size = CARD_SIZE
	slot.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	slot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	slot.add_theme_stylebox_override("panel", _make_style(Color(0.0, 0.0, 0.0, 0.0), Color(1.0, 1.0, 1.0, 0.0), 0, 8))

	var label := Label.new()
	label.text = "Brak kart"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 13)
	label.modulate = Color(1.0, 1.0, 1.0, 0.26)
	slot.add_child(label)

	return slot


func _create_card_view(card: CardData, hidden: bool, animate_enter: bool = true, animate_delay: float = 0.0) -> Control:
	var card_slot := Control.new()
	card_slot.custom_minimum_size = CARD_SIZE
	card_slot.size = CARD_SIZE
	card_slot.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	card_slot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	card_slot.clip_contents = false
	card_slot.mouse_filter = Control.MOUSE_FILTER_STOP

	var visual_layer := Control.new()
	visual_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	visual_layer.pivot_offset = CARD_SIZE * 0.5
	visual_layer.scale = Vector2(0.94, 0.94) if animate_enter else Vector2.ONE
	visual_layer.rotation_degrees = randf_range(-CARD_TILT_RANGE, CARD_TILT_RANGE)
	visual_layer.modulate = Color(1.0, 1.0, 1.0, 0.0) if animate_enter else Color.WHITE
	card_slot.add_child(visual_layer)
	card_slot.mouse_entered.connect(_on_card_mouse_entered.bind(visual_layer))
	card_slot.mouse_exited.connect(_on_card_mouse_exited.bind(visual_layer))

	var shadow := ColorRect.new()
	shadow.color = Color(0.0, 0.0, 0.0, 0.32)
	shadow.position = Vector2(4, 5)
	shadow.size = CARD_SIZE - Vector2(5, 6)
	visual_layer.add_child(shadow)

	if hidden:
		var back_texture := TextureRect.new()
		back_texture.texture = CARD_BACK_TEXTURE
		back_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		back_texture.stretch_mode = TextureRect.STRETCH_SCALE
		back_texture.set_anchors_preset(Control.PRESET_FULL_RECT)
		back_texture.custom_minimum_size = Vector2.ZERO
		visual_layer.add_child(back_texture)
		if animate_enter:
			call_deferred("_animate_card_enter", visual_layer, animate_delay)
		return card_slot

	var card_root := Control.new()
	card_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	visual_layer.add_child(card_root)

	var front_texture := TextureRect.new()
	front_texture.texture = CARD_FRONT_TEXTURE
	front_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	front_texture.stretch_mode = TextureRect.STRETCH_SCALE
	front_texture.set_anchors_preset(Control.PRESET_FULL_RECT)
	front_texture.custom_minimum_size = Vector2.ZERO
	card_root.add_child(front_texture)

	var top_corner := _create_corner_label(card, false)
	top_corner.position = Vector2(14, 13)
	card_root.add_child(top_corner)

	var bottom_corner := _create_corner_label(card, false)
	bottom_corner.position = Vector2(CARD_SIZE.x - 34, CARD_SIZE.y - 43)
	card_root.add_child(bottom_corner)

	var center_symbol := Label.new()
	center_symbol.text = _get_suit_symbol(card.suit)
	center_symbol.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center_symbol.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	center_symbol.add_theme_color_override("font_color", _get_suit_color(card.suit))
	center_symbol.add_theme_font_size_override("font_size", 36)
	center_symbol.set_anchors_preset(Control.PRESET_FULL_RECT)
	card_root.add_child(center_symbol)

	if animate_enter:
		call_deferred("_animate_card_enter", visual_layer, animate_delay)
	return card_slot


func _animate_card_enter(visual_layer: Control, delay: float = 0.0) -> void:
	if not is_instance_valid(visual_layer):
		return

	var final_rotation := visual_layer.rotation_degrees
	var final_global_position := visual_layer.global_position
	var viewport_size := get_viewport_rect().size
	var deck_global_position := Vector2(viewport_size.x - 150.0, viewport_size.y * 0.50)
	JuiceManager.play_card_draw(visual_layer, deck_global_position, final_global_position, final_rotation, delay)


func _on_card_mouse_entered(visual_layer: Control) -> void:
	if not is_instance_valid(visual_layer):
		return

	JuiceManager.play_hover_effect(visual_layer, true, CARD_HOVER_OFFSET)


func _on_card_mouse_exited(visual_layer: Control) -> void:
	if not is_instance_valid(visual_layer):
		return

	JuiceManager.play_hover_effect(visual_layer, false, CARD_HOVER_OFFSET)


func _pulse_message() -> void:
	JuiceManager.pulse_label(message_label, 1.05, 0.18)


func _play_result_feedback(result: String, payout: int) -> void:
	match result:
		BlackjackResult.PLAYER_BLACKJACK:
			JuiceManager.play_blackjack(self, result_burst_label, money_label, debt_label, flash_overlay, payout)
		BlackjackResult.PLAYER_WIN, BlackjackResult.DEALER_BUST:
			JuiceManager.play_round_win(self, result_burst_label, money_label, flash_overlay, payout)
		BlackjackResult.PUSH:
			JuiceManager.play_round_push(result_burst_label, flash_overlay)
		BlackjackResult.DEALER_BLACKJACK, BlackjackResult.DEALER_WIN, BlackjackResult.PLAYER_BUST:
			JuiceManager.play_round_loss(result_burst_label, message_label, flash_overlay, _get_loss_burst_text(result))


func _create_corner_label(card: CardData, flipped: bool) -> Control:
	var box := VBoxContainer.new()
	box.custom_minimum_size = Vector2(23, 34)
	box.add_theme_constant_override("separation", -3)

	var rank_label := Label.new()
	rank_label.text = card.rank
	rank_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rank_label.add_theme_color_override("font_color", _get_suit_color(card.suit))
	rank_label.add_theme_font_size_override("font_size", 13)
	box.add_child(rank_label)

	var suit_label := Label.new()
	suit_label.text = _get_suit_symbol(card.suit)
	suit_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	suit_label.add_theme_color_override("font_color", _get_suit_color(card.suit))
	suit_label.add_theme_font_size_override("font_size", 13)
	box.add_child(suit_label)

	return box


func _clear_children(node: Node) -> void:
	for child: Node in node.get_children():
		node.remove_child(child)
		child.queue_free()


func _get_suit_color(suit: String) -> Color:
	if suit == "Hearts" or suit == "Diamonds":
		return Color(0.66, 0.05, 0.08)

	return Color(0.05, 0.05, 0.05)


func _get_suit_symbol(suit: String) -> String:
	match suit:
		"Spades":
			return "♠"
		"Hearts":
			return "♥"
		"Diamonds":
			return "♦"
		"Clubs":
			return "♣"

	return "?"


func _make_style(bg_color: Color, border_color: Color, border_width: int, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.content_margin_left = 8
	style.content_margin_top = 6
	style.content_margin_right = 8
	style.content_margin_bottom = 6
	return style


func _get_result_text(result: String) -> String:
	match result:
		BlackjackResult.PLAYER_BLACKJACK:
			return "Blackjack."
		BlackjackResult.DEALER_BLACKJACK:
			return "Krupier ma blackjacka."
		BlackjackResult.PLAYER_WIN:
			return "Wygrywasz."
		BlackjackResult.DEALER_WIN:
			return "Krupier wygrywa."
		BlackjackResult.PUSH:
			return "Remis."
		BlackjackResult.PLAYER_BUST:
			return "Przebijasz."
		BlackjackResult.DEALER_BUST:
			return "Krupier przebija. Wygrywasz."

	return "Runda rozliczona."


func _get_loss_burst_text(result: String) -> String:
	match result:
		BlackjackResult.PLAYER_BUST:
			return "PRZEBICIE"
		BlackjackResult.DEALER_BLACKJACK:
			return "BLACKJACK KASYNA"
		BlackjackResult.DEALER_WIN:
			return "KASYNO WYGRYWA"

	return "PORAŻKA"
