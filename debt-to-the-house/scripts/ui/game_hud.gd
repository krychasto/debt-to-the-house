extends Control
class_name GameHud

const GREEN := Color(0.35, 1.0, 0.58)
const RED := Color(1.0, 0.18, 0.32)
const TEXT := Color(0.92, 1.0, 0.97)

var money_value_label: Label
var debt_value_label: Label
var debt_progress_bar: ProgressBar
var status_line_label: Label
var _money_panel: Control
var _debt_group: Control

var hands_value_label: Label
var stage_value_label: Label
var tokens_value_label: Label
var combo_value_label: Label

var _has_snapshot := false
var _last_money := 0
var _last_debt := 0
var _last_hands := 0
var _last_stage := 0
var _last_tokens := 0
var _last_combo := 0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bind_nodes()


func _bind_nodes() -> void:
	if is_instance_valid(money_value_label):
		return

	money_value_label = get_node_or_null("TopBar/MoneyPanel/Box/MoneyValue") as Label
	debt_value_label = get_node_or_null("TopBar/DebtGroup/DebtValue") as Label
	debt_progress_bar = get_node_or_null("TopBar/DebtGroup/DebtProgress") as ProgressBar
	status_line_label = get_node_or_null("TopBar/RunStatusLine") as Label
	_money_panel = get_node_or_null("TopBar/MoneyPanel") as Control
	_debt_group = get_node_or_null("TopBar/DebtGroup") as Control
	hands_value_label = status_line_label
	stage_value_label = status_line_label
	tokens_value_label = status_line_label
	combo_value_label = status_line_label


func update_from_run_manager(run_manager: RunManager) -> void:
	_bind_nodes()
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
	status_line_label.text = "Stage %d • Hands %d • Combo %s • 🪙 %d" % [
		stage,
		hands,
		run_manager.get_combo_display_text(),
		tokens,
	]
	_update_debt_progress(money, debt)

	if not _has_snapshot:
		_store_snapshot(money, debt, hands, stage, tokens, combo)
		return

	if money != _last_money:
		_flash_value(money_value_label, GREEN if money > _last_money else RED)
		JuiceManager.pulse_label(_money_panel, 1.055, 0.16)
	if debt != _last_debt:
		JuiceManager.pulse_label(_debt_group, 1.025, 0.14)
	if hands != _last_hands:
		JuiceManager.pulse_label(status_line_label, 1.025, 0.12)
	if stage != _last_stage or tokens != _last_tokens:
		JuiceManager.pulse_label(status_line_label, 1.025, 0.12)
	if combo > _last_combo:
		JuiceManager.pulse_label(status_line_label, 1.09, 0.18)
	elif combo < _last_combo:
		JuiceShake.shake_node(status_line_label, 5.0, 0.16)

	_store_snapshot(money, debt, hands, stage, tokens, combo)


func _update_debt_progress(money: int, debt: int) -> void:
	if not is_instance_valid(debt_progress_bar):
		return

	debt_progress_bar.max_value = maxf(float(debt), 1.0)
	debt_progress_bar.value = clampf(float(money), 0.0, debt_progress_bar.max_value)


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
