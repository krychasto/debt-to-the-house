extends Node3D
class_name ConceptCasinoTable

const DEFAULT_BET := 10
const CARD_BACK_TEXTURE := preload("res://assets/ui/card_back.png")
const CARD_FRONT_TEXTURE := preload("res://assets/ui/card_front.png")
const TABLE_SIZE := Vector2(11.8, 6.6)
const SURFACE_Y := 0.0
const PANEL_Y := 0.045
const DETAIL_Y := 0.088
const NEON_Y := 0.115
const CARD_SIZE := Vector2(0.68, 0.94)
const CARD_Y := 0.19
const CARD_SPACING := 0.56
const CYAN := Color(0.25, 1.0, 1.0)
const PURPLE := Color(0.82, 0.45, 1.0)

var engine: BlackjackEngine = BlackjackEngine.new()
var run_manager: RunManager = RunManager.new()
var bet: int = DEFAULT_BET
var dealer_cards_root: Node3D
var player_cards_root: Node3D
var status_label: Label3D
var dealer_score_label: Label3D
var player_score_label: Label3D
var message_label: Label3D
var buttons: Dictionary = {}

var mat_floor: StandardMaterial3D
var mat_base: StandardMaterial3D
var mat_panel: StandardMaterial3D
var mat_dark_panel: StandardMaterial3D
var mat_edge: StandardMaterial3D
var mat_line: StandardMaterial3D
var mat_wear_light: StandardMaterial3D
var mat_wear_dark: StandardMaterial3D
var mat_cyan: StandardMaterial3D
var mat_purple: StandardMaterial3D
var mat_circuit: StandardMaterial3D


func _ready() -> void:
	add_child(run_manager)
	_build_materials()
	_add_world()
	_add_camera()
	_add_lights()
	_add_floor()
	_add_table()
	_add_panel_layout()
	_add_neons()
	_add_tech_panels()
	_add_slot_panels()
	_add_corners_and_cutouts()
	_add_wear()
	_add_gameplay_layer()
	_update_view()


func _build_materials() -> void:
	mat_floor = _make_metal(Color(0.030, 0.034, 0.037), 0.0, 0.92)
	mat_base = _make_metal(Color(0.060, 0.070, 0.073), 0.28, 0.74)
	mat_panel = _make_metal(Color(0.090, 0.102, 0.104), 0.36, 0.67)
	mat_dark_panel = _make_metal(Color(0.028, 0.033, 0.036), 0.18, 0.84)
	mat_edge = _make_metal(Color(0.018, 0.022, 0.024), 0.42, 0.58)
	mat_line = _make_metal(Color(0.230, 0.280, 0.285), 0.22, 0.72)
	mat_wear_light = _make_metal(Color(0.390, 0.430, 0.420), 0.18, 0.86)
	mat_wear_dark = _make_metal(Color(0.006, 0.008, 0.010), 0.08, 0.92)
	mat_cyan = _make_emission(CYAN, 2.8)
	mat_purple = _make_emission(PURPLE, 2.4)
	mat_circuit = _make_emission(Color(0.18, 0.85, 0.92), 1.15)


func _add_world() -> void:
	var world := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.006, 0.008, 0.010)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.16, 0.19, 0.20)
	environment.ambient_light_energy = 0.42
	environment.glow_enabled = true
	environment.glow_intensity = 0.42
	environment.glow_bloom = 0.18
	environment.volumetric_fog_enabled = true
	environment.volumetric_fog_density = 0.022
	environment.volumetric_fog_albedo = Color(0.22, 0.28, 0.32)
	world.environment = environment
	add_child(world)


func _add_camera() -> void:
	var camera := Camera3D.new()
	camera.name = "ConceptCamera"
	camera.current = true
	camera.position = Vector3(0.0, 6.4, 5.9)
	camera.rotation_degrees = Vector3(-58.0, 0.0, 0.0)
	camera.fov = 46.0
	camera.near = 0.05
	camera.far = 80.0
	add_child(camera)


func _add_lights() -> void:
	var key := DirectionalLight3D.new()
	key.rotation_degrees = Vector3(-62.0, -20.0, 0.0)
	key.light_energy = 1.45
	key.shadow_enabled = true
	add_child(key)

	var soft := OmniLight3D.new()
	soft.position = Vector3(0.0, 3.6, 1.4)
	soft.light_color = Color(0.62, 0.78, 0.88)
	soft.light_energy = 1.15
	soft.omni_range = 8.0
	add_child(soft)

	var rim := OmniLight3D.new()
	rim.position = Vector3(2.8, 2.0, -2.7)
	rim.light_color = PURPLE
	rim.light_energy = 0.55
	rim.omni_range = 5.2
	add_child(rim)


func _add_floor() -> void:
	_add_box("Floor", Vector3(0.0, -0.09, 0.0), Vector3(16.0, 0.08, 9.0), mat_floor)
	for x: float in [-5.9, -2.95, 0.0, 2.95, 5.9]:
		_add_line(Vector3(x, -0.038, 0.0), Vector3(0.025, 0.010, 8.8), mat_edge)
	for z: float in [-3.3, 0.0, 3.3]:
		_add_line(Vector3(0.0, -0.037, z), Vector3(15.8, 0.010, 0.025), mat_edge)


func _add_table() -> void:
	_add_box("MainBody", Vector3(0.0, -0.06, 0.0), Vector3(TABLE_SIZE.x, 0.20, TABLE_SIZE.y), mat_base)
	_add_box("OuterTopPlate", Vector3(0.0, SURFACE_Y, 0.0), Vector3(10.8, 0.08, 5.76), mat_panel)
	_add_box("CentralPlayArea", Vector3(0.0, PANEL_Y, 0.02), Vector3(4.85, 0.045, 3.42), mat_dark_panel)
	_add_rect_outline(Vector3(0.0, DETAIL_Y, 0.02), Vector2(5.08, 3.62), mat_line, 0.035)

	_add_box("TopFrame", Vector3(0.0, PANEL_Y, -2.55), Vector3(7.95, 0.08, 0.40), mat_edge)
	_add_box("BottomFrame", Vector3(0.0, PANEL_Y, 2.55), Vector3(7.95, 0.08, 0.40), mat_edge)
	_add_box("LeftFrame", Vector3(-4.28, PANEL_Y, 0.0), Vector3(0.42, 0.08, 4.72), mat_edge)
	_add_box("RightFrame", Vector3(4.28, PANEL_Y, 0.0), Vector3(0.42, 0.08, 4.72), mat_edge)


func _add_panel_layout() -> void:
	for x: float in [-5.0, 5.0]:
		_add_box("SideWing", Vector3(x, PANEL_Y, 0.0), Vector3(1.55, 0.075, 4.85), mat_panel)
		_add_rect_outline(Vector3(x, DETAIL_Y, 0.0), Vector2(1.34, 4.52), mat_line, 0.025)

	for x: float in [-3.4, 3.4]:
		_add_box("InnerSideLane", Vector3(x, PANEL_Y + 0.004, 0.0), Vector3(1.08, 0.050, 4.38), mat_dark_panel)
		_add_rect_outline(Vector3(x, DETAIL_Y + 0.006, 0.0), Vector2(0.90, 4.08), mat_line, 0.020)

	for x: float in [-2.9, 0.0, 2.9]:
		_add_box("TopPlate", Vector3(x, PANEL_Y, -3.15), Vector3(2.32, 0.075, 0.98), mat_panel)
		_add_rect_outline(Vector3(x, DETAIL_Y, -3.15), Vector2(2.10, 0.78), mat_line, 0.020)

	for x: float in [-2.8, 2.8]:
		_add_box("BottomPlate", Vector3(x, PANEL_Y, 3.08), Vector3(2.50, 0.075, 0.92), mat_panel)
		_add_rect_outline(Vector3(x, DETAIL_Y, 3.08), Vector2(2.25, 0.70), mat_line, 0.020)


func _add_neons() -> void:
	_add_neon_strip("TopCyanLeft", Vector3(-2.95, NEON_Y, -2.42), Vector3(1.55, 0.055, 0.045), mat_cyan)
	_add_neon_strip("TopCyanCenter", Vector3(-0.65, NEON_Y, -2.42), Vector3(1.75, 0.055, 0.045), mat_cyan)
	_add_neon_strip("LeftCyanVertical", Vector3(-4.54, NEON_Y, -0.48), Vector3(0.050, 0.055, 2.05), mat_cyan)
	_add_neon_strip("BottomCyanLeft", Vector3(-2.45, NEON_Y, 2.42), Vector3(1.55, 0.055, 0.045), mat_cyan)
	_add_neon_strip("BottomCyanCenter", Vector3(-0.18, NEON_Y, 2.42), Vector3(1.55, 0.055, 0.045), mat_cyan)

	_add_neon_strip("TopPurpleRight", Vector3(2.55, NEON_Y, -2.42), Vector3(1.55, 0.055, 0.045), mat_purple)
	_add_neon_strip("RightPurpleVertical", Vector3(4.54, NEON_Y, -0.02), Vector3(0.050, 0.055, 1.95), mat_purple)
	_add_neon_strip("BottomPurpleRight", Vector3(2.70, NEON_Y, 2.42), Vector3(1.25, 0.055, 0.045), mat_purple)


func _add_tech_panels() -> void:
	_add_circuit_panel(Vector3(-5.05, DETAIL_Y, -1.40), Vector2(1.05, 1.35), 4)
	_add_circuit_panel(Vector3(0.20, DETAIL_Y, 3.08), Vector2(1.10, 0.72), 5)
	_add_circuit_panel(Vector3(0.10, DETAIL_Y, -3.14), Vector2(0.86, 0.70), 3)
	_add_circuit_panel(Vector3(2.45, DETAIL_Y, -3.14), Vector2(1.10, 0.70), 5)


func _add_slot_panels() -> void:
	_add_grid_panel(Vector3(-3.38, DETAIL_Y, -1.42), Vector2(0.80, 0.92), 6, 8)
	_add_grid_panel(Vector3(-3.38, DETAIL_Y, -0.02), Vector2(0.82, 0.94), 5, 7)
	_add_hex_panel(Vector3(-3.38, DETAIL_Y, 1.54), Vector2(0.86, 0.68))

	_add_hex_panel(Vector3(3.40, DETAIL_Y, -1.70), Vector2(0.88, 0.60))
	_add_box("RightBlankSlot", Vector3(3.40, DETAIL_Y, -0.10), Vector3(0.82, 0.018, 0.78), mat_dark_panel)
	_add_rect_outline(Vector3(3.40, DETAIL_Y + 0.014, -0.10), Vector2(0.82, 0.78), mat_line, 0.018)
	_add_hex_panel(Vector3(3.40, DETAIL_Y, 1.55), Vector2(0.86, 0.68))

	_add_box("RightLongSlot", Vector3(5.05, DETAIL_Y, -0.40), Vector3(1.04, 0.040, 1.85), mat_dark_panel)
	_add_rect_outline(Vector3(5.05, DETAIL_Y + 0.018, -0.40), Vector2(0.88, 1.62), mat_line, 0.020)
	for index: int in range(5):
		_add_line(Vector3(5.05, DETAIL_Y + 0.030, -1.05 + index * 0.23), Vector3(0.72, 0.014, 0.018), mat_line)
	_add_hex_panel(Vector3(5.05, DETAIL_Y + 0.032, 0.62), Vector2(0.55, 0.42))


func _add_corners_and_cutouts() -> void:
	for x: float in [-5.82, 5.82]:
		for z: float in [-2.95, 2.95]:
			_add_box("CornerPlate", Vector3(x, PANEL_Y + 0.01, z), Vector3(0.68, 0.10, 0.66), mat_edge)

	# Dark placeholder plates emulate the concept art's hard mechanical cutouts.
	for position: Vector3 in [
		Vector3(-1.40, DETAIL_Y, -2.44),
		Vector3(1.55, DETAIL_Y, -2.44),
		Vector3(-1.05, DETAIL_Y, 2.44),
		Vector3(1.35, DETAIL_Y, 2.44),
	]:
		_add_box("FrameCutout", position, Vector3(0.68, 0.030, 0.22), mat_dark_panel)


func _add_wear() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 20260708
	for index: int in range(115):
		var center_bias := rng.randf()
		var x := rng.randf_range(-2.25, 2.25) if center_bias < 0.70 else rng.randf_range(-5.1, 5.1)
		var z := rng.randf_range(-1.55, 1.55) if center_bias < 0.70 else rng.randf_range(-2.85, 2.85)
		var length := rng.randf_range(0.10, 0.56)
		var width := rng.randf_range(0.006, 0.018)
		var material := mat_wear_light if rng.randf() > 0.34 else mat_wear_dark
		var scratch := _add_line(Vector3(x, DETAIL_Y + 0.026, z), Vector3(length, 0.006, width), material)
		scratch.rotation_degrees.y = rng.randf_range(-34.0, 34.0)

	for index: int in range(42):
		var scuff := _add_box("Scuff", Vector3(rng.randf_range(-5.2, 5.2), DETAIL_Y + 0.018, rng.randf_range(-3.0, 3.0)), Vector3(rng.randf_range(0.035, 0.12), 0.005, rng.randf_range(0.025, 0.090)), mat_wear_dark)
		scuff.rotation_degrees.y = rng.randf_range(0.0, 180.0)


func _add_gameplay_layer() -> void:
	status_label = _create_table_label(Vector3(-4.95, 0.20, -2.90), 20)
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	add_child(status_label)

	var dealer_title := _create_table_label(Vector3(-2.70, 0.20, -1.98), 21)
	dealer_title.text = "DEALER"
	dealer_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	add_child(dealer_title)

	var player_title := _create_table_label(Vector3(-2.70, 0.20, 1.58), 21)
	player_title.text = "PLAYER"
	player_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	add_child(player_title)

	dealer_score_label = _create_table_label(Vector3(2.55, 0.20, -1.98), 22)
	dealer_score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	add_child(dealer_score_label)

	player_score_label = _create_table_label(Vector3(2.55, 0.20, 1.58), 22)
	player_score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	add_child(player_score_label)

	message_label = _create_table_label(Vector3(0.0, 0.20, -0.08), 20)
	message_label.text = "Set your bet and deal."
	add_child(message_label)

	dealer_cards_root = Node3D.new()
	dealer_cards_root.position = Vector3(0.0, CARD_Y, -1.28)
	add_child(dealer_cards_root)

	player_cards_root = Node3D.new()
	player_cards_root.position = Vector3(0.0, CARD_Y, 1.18)
	add_child(player_cards_root)

	_add_button("bet_down", "-5", Vector3(-2.65, 0.20, 2.88), Vector2(0.55, 0.34))
	_add_button("bet_up", "+5", Vector3(-1.98, 0.20, 2.88), Vector2(0.55, 0.34))
	_add_button("max_bet", "MAX", Vector3(-1.22, 0.20, 2.88), Vector2(0.70, 0.34))
	_add_button("deal", "DEAL", Vector3(-0.22, 0.20, 2.88), Vector2(0.90, 0.38))
	_add_button("hit", "HIT", Vector3(0.86, 0.20, 2.88), Vector2(0.98, 0.38))
	_add_button("stand", "STAND", Vector3(1.96, 0.20, 2.88), Vector2(0.84, 0.38))
	_add_button("retry", "RETRY", Vector3(3.02, 0.20, 2.88), Vector2(0.98, 0.38))


func _add_button(action: String, text: String, position: Vector3, size: Vector2) -> void:
	var root := Node3D.new()
	root.name = "Button_%s" % action
	root.position = position
	add_child(root)

	var base := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(size.x, 0.075, size.y)
	base.mesh = box
	base.position = Vector3.ZERO
	base.material_override = _make_metal(Color(0.055, 0.030, 0.045), 0.18, 0.62)
	root.add_child(base)

	var glow := _add_box("ButtonGlow", position + Vector3(0.0, 0.052, 0.0), Vector3(size.x * 0.92, 0.018, 0.030), mat_cyan)
	glow.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	var area := Area3D.new()
	var shape := CollisionShape3D.new()
	var box_shape := BoxShape3D.new()
	box_shape.size = Vector3(size.x, 0.22, size.y)
	shape.shape = box_shape
	area.add_child(shape)
	area.input_event.connect(_on_button_input.bind(action))
	root.add_child(area)

	var label := _create_table_label(Vector3(0.0, 0.075, 0.0), 13)
	label.text = text
	root.add_child(label)

	buttons[action] = {
		"root": root,
		"mesh": base,
		"label": label,
		"glow": glow,
		"enabled": true,
	}


func _on_button_input(_camera: Node, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int, action: String) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not buttons.get(action, {}).get("enabled", false):
			return
		_handle_action(action)


func _handle_action(action: String) -> void:
	match action:
		"bet_down":
			bet = clampi(bet - 5, 1, max(1, run_manager.money))
		"bet_up":
			bet = clampi(bet + 5, 1, max(1, run_manager.money))
		"max_bet":
			bet = max(1, run_manager.money)
		"deal":
			_start_hand()
		"hit":
			_hit()
		"stand":
			_stand()
		"retry":
			_retry()

	_update_view()


func _start_hand() -> void:
	if not run_manager.start_hand(bet):
		message_label.text = "You cannot play with that bet."
		return

	engine.start_round(bet)
	message_label.text = "Your move."

	var opening_result := engine.resolve_round() if _has_opening_blackjack() else ""
	if opening_result != "":
		_apply_round_result(opening_result)


func _hit() -> void:
	var result := engine.player_hit()
	if result != "":
		_apply_round_result(result)
	else:
		message_label.text = "Card drawn."


func _stand() -> void:
	var result := engine.player_stand()
	if result != "":
		_apply_round_result(result)


func _retry() -> void:
	run_manager.reset_run()
	engine = BlackjackEngine.new()
	bet = DEFAULT_BET
	message_label.text = "New run."


func _has_opening_blackjack() -> bool:
	return engine.player_hand.is_blackjack(engine.rules) or engine.dealer_hand.is_blackjack(engine.rules)


func _apply_round_result(result: String) -> void:
	var money_before := run_manager.money
	var payout := run_manager.apply_result(result, engine.current_bet, engine.rules)
	message_label.text = "%s $%d -> $%d" % [_get_result_text(result), money_before, run_manager.money]
	if payout > 0:
		message_label.text += " (+$%d)" % payout

	if run_manager.is_stage_success():
		message_label.text += " DEBT PAID."
	elif run_manager.is_game_over():
		message_label.text += " HOUSE WINS."


func _update_view() -> void:
	status_label.text = "Debt to the House\nStage %d | Money $%d | Bet $%d\nDebt $%d | Hands %d | Combo %s" % [
		run_manager.stage,
		run_manager.money,
		bet,
		run_manager.debt_target,
		run_manager.hands_left,
		run_manager.get_combo_display_text(),
	]

	var player_value := engine.player_hand.get_value(engine.rules) if not engine.player_hand.cards.is_empty() else 0
	var dealer_value := engine.dealer_hand.get_value(engine.rules) if not engine.dealer_hand.cards.is_empty() else 0
	player_score_label.text = "SCORE %d" % player_value if player_value > 0 else "SCORE -"
	dealer_score_label.text = "SCORE ?" if engine.is_round_active and engine.dealer_hand.cards.size() > 1 else ("SCORE %d" % dealer_value if dealer_value > 0 else "SCORE -")

	_render_cards(player_cards_root, engine.player_hand, false)
	_render_cards(dealer_cards_root, engine.dealer_hand, engine.is_round_active)
	_update_buttons()


func _render_cards(root: Node3D, hand: Hand, hide_hole_card: bool) -> void:
	for child: Node in root.get_children():
		child.queue_free()

	var count := hand.cards.size()
	if count == 0:
		return

	var start_x := -((count - 1) * CARD_SPACING) * 0.5
	for index: int in range(count):
		var card := hand.cards[index]
		var hidden := hide_hole_card and index == 1
		var card_node := _create_card_3d(card, hidden)
		card_node.position = Vector3(start_x + index * CARD_SPACING, index * 0.014, 0.0)
		card_node.rotation_degrees = Vector3(0.0, randf_range(-2.4, 2.4), 0.0)
		root.add_child(card_node)


func _create_card_3d(card: CardData, hidden: bool) -> Node3D:
	var root := Node3D.new()

	var shadow := MeshInstance3D.new()
	var shadow_mesh := PlaneMesh.new()
	shadow_mesh.size = CARD_SIZE
	shadow.mesh = shadow_mesh
	shadow.position = Vector3(0.035, -0.012, 0.045)
	shadow.material_override = _make_metal(Color(0.0, 0.0, 0.0, 0.46), 0.0, 0.94)
	root.add_child(shadow)

	var card_mesh := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = CARD_SIZE
	card_mesh.mesh = plane
	card_mesh.material_override = _make_texture_material(CARD_BACK_TEXTURE if hidden else CARD_FRONT_TEXTURE)
	root.add_child(card_mesh)

	if not hidden:
		_add_card_labels(root, card)

	return root


func _add_card_labels(root: Node3D, card: CardData) -> void:
	var suit := _get_suit_symbol(card.suit)
	var color := _get_suit_color(card.suit)

	var top := _create_table_label(Vector3(-0.22, 0.042, -0.30), 13)
	top.text = "%s\n%s" % [card.rank, suit]
	top.modulate = color
	root.add_child(top)

	var center := _create_table_label(Vector3(0.0, 0.048, 0.03), 31)
	center.text = suit
	center.modulate = color
	root.add_child(center)


func _update_buttons() -> void:
	var stage_ready := run_manager.is_stage_success() and not engine.is_round_active
	var game_over := run_manager.is_game_over() and not engine.is_round_active
	_set_button_enabled("deal", not engine.is_round_active and not stage_ready and not game_over and run_manager.can_play_hand())
	_set_button_enabled("hit", engine.is_round_active)
	_set_button_enabled("stand", engine.is_round_active)
	_set_button_enabled("retry", game_over)
	_set_button_enabled("bet_down", not engine.is_round_active and not stage_ready and not game_over)
	_set_button_enabled("bet_up", not engine.is_round_active and not stage_ready and not game_over)
	_set_button_enabled("max_bet", not engine.is_round_active and not stage_ready and not game_over)


func _set_button_enabled(action: String, enabled: bool) -> void:
	if not buttons.has(action):
		return

	buttons[action]["enabled"] = enabled
	var mesh := buttons[action]["mesh"] as MeshInstance3D
	var label := buttons[action]["label"] as Label3D
	var glow := buttons[action]["glow"] as MeshInstance3D
	mesh.transparency = 0.0 if enabled else 0.48
	label.modulate = Color(0.92, 1.0, 0.95) if enabled else Color(0.45, 0.43, 0.42)
	glow.visible = enabled


func _create_table_label(position: Vector3, font_size: int) -> Label3D:
	var label := Label3D.new()
	label.position = position
	label.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
	label.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	label.font_size = font_size
	label.modulate = Color(0.92, 0.94, 0.88)
	label.outline_size = 6
	label.outline_modulate = Color(0.01, 0.012, 0.014, 0.95)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return label


func _get_suit_color(suit: String) -> Color:
	if suit == "Hearts" or suit == "Diamonds":
		return Color(0.70, 0.03, 0.06)
	return Color(0.04, 0.035, 0.03)


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


func _get_result_text(result: String) -> String:
	match result:
		BlackjackResult.PLAYER_BLACKJACK:
			return "Blackjack."
		BlackjackResult.DEALER_BLACKJACK:
			return "Dealer blackjack."
		BlackjackResult.PLAYER_WIN:
			return "You win."
		BlackjackResult.DEALER_WIN:
			return "Dealer wins."
		BlackjackResult.PUSH:
			return "Push."
		BlackjackResult.PLAYER_BUST:
			return "You bust."
		BlackjackResult.DEALER_BUST:
			return "Dealer busts."
	return "Round resolved."


func _add_circuit_panel(center: Vector3, size: Vector2, complexity: int) -> void:
	_add_box("CircuitPanel", center, Vector3(size.x, 0.035, size.y), mat_dark_panel)
	_add_rect_outline(center + Vector3(0.0, 0.018, 0.0), size, mat_line, 0.018)
	for index: int in range(complexity):
		var x := center.x - size.x * 0.34 + index * size.x * 0.15
		_add_line(Vector3(x, center.y + 0.036, center.z), Vector3(0.020, 0.012, size.y * 0.62), mat_circuit)
		_add_line(Vector3(x + size.x * 0.08, center.y + 0.037, center.z - size.y * 0.20), Vector3(size.x * 0.24, 0.012, 0.018), mat_circuit)
		_add_line(Vector3(x + size.x * 0.13, center.y + 0.038, center.z + size.y * 0.18), Vector3(size.x * 0.16, 0.012, 0.018), mat_circuit)
		_add_box("CircuitNode", Vector3(x + size.x * 0.23, center.y + 0.044, center.z + size.y * 0.31), Vector3(0.035, 0.018, 0.035), mat_circuit)


func _add_grid_panel(center: Vector3, size: Vector2, columns: int, rows: int) -> void:
	_add_rect_outline(center, size, mat_line, 0.018)
	for column: int in range(columns + 1):
		var x := center.x - size.x * 0.5 + size.x * float(column) / float(columns)
		_add_line(Vector3(x, center.y + 0.018, center.z), Vector3(0.010, 0.010, size.y), mat_line)
	for row: int in range(rows + 1):
		var z := center.z - size.y * 0.5 + size.y * float(row) / float(rows)
		_add_line(Vector3(center.x, center.y + 0.019, z), Vector3(size.x, 0.010, 0.010), mat_line)


func _add_hex_panel(center: Vector3, size: Vector2) -> void:
	_add_rect_outline(center, size, mat_line, 0.018)
	var offsets := [
		Vector2(0.0, 0.0),
		Vector2(-0.18, -0.13),
		Vector2(0.18, -0.13),
		Vector2(-0.18, 0.13),
		Vector2(0.18, 0.13),
		Vector2(0.0, -0.27),
		Vector2(0.0, 0.27),
	]
	for offset: Vector2 in offsets:
		_add_hex_outline(Vector3(center.x + offset.x, center.y + 0.026, center.z + offset.y), 0.13, mat_line)


func _add_hex_outline(center: Vector3, radius: float, material: Material) -> void:
	var points: Array[Vector2] = []
	for index: int in range(6):
		var angle := deg_to_rad(60.0 * index + 30.0)
		points.append(Vector2(cos(angle) * radius, sin(angle) * radius))
	for index: int in range(6):
		var a := points[index]
		var b := points[(index + 1) % 6]
		var midpoint := (a + b) * 0.5
		var length := a.distance_to(b)
		var line := _add_line(Vector3(center.x + midpoint.x, center.y, center.z + midpoint.y), Vector3(length, 0.010, 0.012), material)
		line.rotation_degrees.y = -rad_to_deg((b - a).angle())


func _add_rect_outline(center: Vector3, size: Vector2, material: Material, thickness: float) -> void:
	_add_line(Vector3(center.x, center.y, center.z - size.y * 0.5), Vector3(size.x, 0.012, thickness), material)
	_add_line(Vector3(center.x, center.y, center.z + size.y * 0.5), Vector3(size.x, 0.012, thickness), material)
	_add_line(Vector3(center.x - size.x * 0.5, center.y, center.z), Vector3(thickness, 0.012, size.y), material)
	_add_line(Vector3(center.x + size.x * 0.5, center.y, center.z), Vector3(thickness, 0.012, size.y), material)


func _add_neon_strip(node_name: String, position: Vector3, size: Vector3, material: Material) -> MeshInstance3D:
	var strip := _add_box(node_name, position, size, material)
	strip.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var glow := OmniLight3D.new()
	glow.position = position + Vector3(0.0, 0.10, 0.0)
	glow.light_color = material.emission if material is StandardMaterial3D else Color.WHITE
	glow.light_energy = 0.28
	glow.omni_range = 1.15
	add_child(glow)
	return strip


func _add_line(position: Vector3, size: Vector3, material: Material) -> MeshInstance3D:
	return _add_box("Line", position, size, material)


func _add_box(node_name: String, position: Vector3, size: Vector3, material: Material) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = node_name
	var box := BoxMesh.new()
	box.size = size
	mesh_instance.mesh = box
	mesh_instance.position = position
	mesh_instance.material_override = material
	add_child(mesh_instance)
	return mesh_instance


func _make_metal(color: Color, metallic: float, roughness: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.metallic = metallic
	material.roughness = roughness
	return material


func _make_emission(color: Color, energy: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = energy
	material.roughness = 0.38
	return material


func _make_texture_material(texture: Texture2D) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_texture = texture
	material.roughness = 0.70
	material.metallic = 0.0
	return material
