extends Control
class_name GameHud

const CYAN := Color(0.18, 0.94, 0.88)
const PURPLE := Color(0.74, 0.34, 1.0)
const GREEN := Color(0.35, 1.0, 0.58)
const RED := Color(1.0, 0.18, 0.32)
const TEXT := Color(0.92, 1.0, 0.97)
const MUTED := Color(0.60, 0.80, 0.84)
const PANEL_BG := Color(0.015, 0.025, 0.04, 0.72)
const INK := Color(0.0, 0.01, 0.02, 0.95)

var money_value_label: Label
var debt_value_label: Label
var hands_value_label: Label
var stage_value_label: Label
var tokens_value_label: Label
var combo_value_label: Label

var _money_panel: Control
var _debt_panel: Control
var _hands_panel: Control
var _stage_panel: Control
var _tokens_panel: Control
var _combo_panel: Control

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
	debt_value_label.text = "$%d" % debt
	hands_value_label.text = "%d" % hands
	stage_value_label.text = "%d" % stage
	tokens_value_label.text = "%d" % tokens
	combo_value_label.text = run_manager.get_combo_display_text()

	if not _has_snapshot:
		_store_snapshot(money, debt, hands, stage, tokens, combo)
		return

	if money != _last_money:
		_flash_value(money_value_label, GREEN if money > _last_money else RED)
		JuiceManager.pulse_label(_money_panel, 1.06, 0.16)
	if debt != _last_debt:
		JuiceManager.pulse_label(_debt_panel, 1.045, 0.16)
	if hands != _last_hands:
		JuiceManager.pulse_label(_hands_panel, 1.045, 0.14)
	if stage != _last_stage:
		JuiceManager.pulse_label(_stage_panel, 1.045, 0.14)
	if tokens != _last_tokens:
		JuiceManager.pulse_label(_tokens_panel, 1.045, 0.14)
	if combo > _last_combo:
		JuiceManager.pulse_label(_combo_panel, 1.12, 0.20)
	elif combo < _last_combo:
		JuiceShake.shake_node(_combo_panel, 5.0, 0.16)

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
	top_bar.offset_bottom = 76.0
	top_bar.add_theme_constant_override("separation", 10)
	add_child(top_bar)

	_money_panel = _create_panel("KASA", CYAN, true)
	money_value_label = _money_panel.get_node("Box/Value") as Label
	top_bar.add_child(_money_panel)

	_debt_panel = _create_panel("DŁUG", PURPLE, true)
	debt_value_label = _debt_panel.get_node("Box/Value") as Label
	top_bar.add_child(_debt_panel)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_bar.add_child(spacer)

	_stage_panel = _create_panel("ETAP", CYAN, false)
	stage_value_label = _stage_panel.get_node("Box/Value") as Label
	top_bar.add_child(_stage_panel)

	_hands_panel = _create_panel("ROZDANIA", CYAN, false)
	hands_value_label = _hands_panel.get_node("Box/Value") as Label
	top_bar.add_child(_hands_panel)

	_tokens_panel = _create_panel("ŻETONY", PURPLE, false)
	tokens_value_label = _tokens_panel.get_node("Box/Value") as Label
	top_bar.add_child(_tokens_panel)

	_combo_panel = _create_panel("COMBO", PURPLE, false)
	combo_value_label = _combo_panel.get_node("Box/Value") as Label
	top_bar.add_child(_combo_panel)


func _create_panel(title: String, accent: Color, is_primary: bool) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.custom_minimum_size = Vector2(146, 58) if is_primary else Vector2(92, 52)
	panel.add_theme_stylebox_override("panel", _make_panel_style(accent))

	var box := VBoxContainer.new()
	box.name = "Box"
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(box)

	var line := ColorRect.new()
	line.color = accent
	line.custom_minimum_size = Vector2(0, 2)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(line)

	var title_label := Label.new()
	title_label.text = title
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 10 if is_primary else 9)
	title_label.add_theme_color_override("font_color", MUTED)
	title_label.add_theme_color_override("font_outline_color", INK)
	title_label.add_theme_constant_override("outline_size", 2)
	box.add_child(title_label)

	var value_label := Label.new()
	value_label.name = "Value"
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	value_label.add_theme_font_size_override("font_size", 24 if is_primary else 18)
	value_label.add_theme_color_override("font_color", TEXT)
	value_label.add_theme_color_override("font_outline_color", INK)
	value_label.add_theme_constant_override("outline_size", 4)
	box.add_child(value_label)

	return panel


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
	style.content_margin_left = 8
	style.content_margin_top = 5
	style.content_margin_right = 8
	style.content_margin_bottom = 5
	style.shadow_color = Color(accent.r, accent.g, accent.b, 0.16)
	style.shadow_size = 8
	style.shadow_offset = Vector2.ZERO
	return style


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
