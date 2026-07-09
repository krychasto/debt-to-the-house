extends Control
class_name GameHud

const CYAN := Color(0.18, 0.94, 0.88)
const PURPLE := Color(0.74, 0.34, 1.0)
const GREEN := Color(0.35, 1.0, 0.58)
const RED := Color(1.0, 0.18, 0.32)
const TEXT := Color(0.92, 1.0, 0.97)
const MUTED := Color(0.60, 0.80, 0.84)
const PANEL_BG := Color(0.015, 0.025, 0.04, 0.66)
const INK := Color(0.0, 0.01, 0.02, 0.95)

var money_value_label: Label
var debt_value_label: Label
var hands_value_label: Label
var stage_value_label: Label
var tokens_value_label: Label
var combo_value_label: Label

var _money_panel: Control
var _debt_group: Control
var _debt_bar_fill: ColorRect
var _meta_label: Label

var _has_snapshot := false
var _last_money := 0
var _last_debt := 0
var _last_hands := 0
var _last_stage := 0
var _last_tokens := 0
var _last_combo := 0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_hud()


func update_from_run_manager(run_manager: RunManager) -> void:
	if not is_instance_valid(money_value_label):
		return

	var money := run_manager.money
	var debt := run_manager.debt_target
	var hands := run_manager.hands_left
	var stage := run_manager.stage
	var tokens := run_manager.tokens
	var combo := run_manager.combo_count

	money_value_label.text = "$%d" % money
	debt_value_label.text = "$%d / $%d" % [money, debt]
	_meta_label.text = "Stage %d • Hands %d • Combo %s • 🪙 %d" % [
		stage,
		hands,
		run_manager.get_combo_display_text(),
		tokens,
	]
	_update_debt_bar(money, debt)

	if not _has_snapshot:
		_store_snapshot(money, debt, hands, stage, tokens, combo)
		return

	if money != _last_money:
		_flash_value(money_value_label, GREEN if money > _last_money else RED)
		JuiceManager.pulse_label(_money_panel, 1.055, 0.16)
	if debt != _last_debt:
		JuiceManager.pulse_label(_debt_group, 1.025, 0.14)
	if hands != _last_hands:
		JuiceManager.pulse_label(_meta_label, 1.025, 0.12)
	if stage != _last_stage or tokens != _last_tokens:
		JuiceManager.pulse_label(_meta_label, 1.025, 0.12)
	if combo > _last_combo:
		JuiceManager.pulse_label(_meta_label, 1.09, 0.18)
	elif combo < _last_combo:
		JuiceShake.shake_node(_meta_label, 5.0, 0.16)

	_store_snapshot(money, debt, hands, stage, tokens, combo)


func _build_hud() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)

	var top_bar := HBoxContainer.new()
	top_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top_bar.anchor_left = 0.0
	top_bar.anchor_right = 1.0
	top_bar.anchor_top = 0.0
	top_bar.anchor_bottom = 0.0
	top_bar.offset_left = 22.0
	top_bar.offset_top = 14.0
	top_bar.offset_right = -58.0
	top_bar.offset_bottom = 74.0
	top_bar.add_theme_constant_override("separation", 12)
	add_child(top_bar)

	_money_panel = _create_money_panel()
	money_value_label = _money_panel.get_node("Box/Value") as Label
	top_bar.add_child(_money_panel)

	_debt_group = _create_debt_group()
	debt_value_label = _debt_group.get_node("Value") as Label
	_debt_bar_fill = _debt_group.get_node("Bar/Fill") as ColorRect
	top_bar.add_child(_debt_group)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_bar.add_child(spacer)

	_meta_label = Label.new()
	_meta_label.custom_minimum_size = Vector2(330, 38)
	_meta_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_meta_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_meta_label.add_theme_font_size_override("font_size", 15)
	_meta_label.add_theme_color_override("font_color", TEXT)
	_meta_label.add_theme_color_override("font_outline_color", INK)
	_meta_label.add_theme_constant_override("outline_size", 4)
	top_bar.add_child(_meta_label)

	hands_value_label = _meta_label
	stage_value_label = _meta_label
	tokens_value_label = _meta_label
	combo_value_label = _meta_label


func _create_money_panel() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.custom_minimum_size = Vector2(178, 58)
	panel.add_theme_stylebox_override("panel", _make_panel_style(CYAN))

	var box := VBoxContainer.new()
	box.name = "Box"
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(box)

	var title_label := _create_caption("MONEY")
	box.add_child(title_label)

	var value_label := _create_value_label(31)
	value_label.name = "Value"
	box.add_child(value_label)

	return panel


func _create_debt_group() -> Control:
	var box := VBoxContainer.new()
	box.name = "Box"
	box.custom_minimum_size = Vector2(208, 54)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_theme_constant_override("separation", 3)

	var title_label := _create_caption("DEBT")
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	box.add_child(title_label)

	var value_label := _create_value_label(16)
	value_label.name = "Value"
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	box.add_child(value_label)

	var bar := Control.new()
	bar.name = "Bar"
	bar.custom_minimum_size = Vector2(208, 7)
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(bar)

	var track := ColorRect.new()
	track.color = Color(0.04, 0.06, 0.08, 0.72)
	track.set_anchors_preset(Control.PRESET_FULL_RECT)
	track.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar.add_child(track)

	var fill := ColorRect.new()
	fill.name = "Fill"
	fill.color = PURPLE
	fill.anchor_left = 0.0
	fill.anchor_right = 0.0
	fill.anchor_top = 0.0
	fill.anchor_bottom = 1.0
	fill.offset_left = 0.0
	fill.offset_right = 0.0
	fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar.add_child(fill)

	return box


func _create_caption(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 10)
	label.add_theme_color_override("font_color", MUTED)
	label.add_theme_color_override("font_outline_color", INK)
	label.add_theme_constant_override("outline_size", 2)
	return label


func _create_value_label(font_size: int) -> Label:
	var label := Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", TEXT)
	label.add_theme_color_override("font_outline_color", INK)
	label.add_theme_constant_override("outline_size", 4)
	return label


func _make_panel_style(accent: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = PANEL_BG
	style.border_color = Color(accent.r, accent.g, accent.b, 0.62)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	style.content_margin_left = 10
	style.content_margin_top = 6
	style.content_margin_right = 10
	style.content_margin_bottom = 6
	style.shadow_color = Color(accent.r, accent.g, accent.b, 0.14)
	style.shadow_size = 8
	style.shadow_offset = Vector2.ZERO
	return style


func _update_debt_bar(money: int, debt: int) -> void:
	if not is_instance_valid(_debt_bar_fill):
		return

	var width := 208.0 * clampf(float(money) / maxf(float(debt), 1.0), 0.0, 1.0)
	_debt_bar_fill.offset_right = width


func _flash_value(label: Label, color: Color) -> void:
	label.add_theme_color_override("font_color", color)
	var tween := create_tween()
	tween.tween_interval(0.12)
	tween.tween_callback(func() -> void:
		if is_instance_valid(label):
			label.add_theme_color_override("font_color", TEXT)
	)


func _store_snapshot(money: int, debt: int, hands: int, stage: int, tokens: int, combo: int) -> void:
	_has_snapshot = true
	_last_money = money
	_last_debt = debt
	_last_hands = hands
	_last_stage = stage
	_last_tokens = tokens
	_last_combo = combo
