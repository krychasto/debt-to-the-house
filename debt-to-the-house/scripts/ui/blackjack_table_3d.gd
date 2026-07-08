extends Node3D

const DEFAULT_BET := 10
const TABLE_TEXTURE := preload("res://assets/ui/table_felt.png")
const CARD_BACK_TEXTURE := preload("res://assets/ui/card_back.png")
const CARD_FRONT_TEXTURE := preload("res://assets/ui/card_front.png")

const CARD_SIZE := Vector2(0.78, 1.08)
const CARD_Y := 0.08
const CARD_SPACING := 0.62

var engine: BlackjackEngine = BlackjackEngine.new()
var run_manager: RunManager = RunManager.new()

var bet: int = DEFAULT_BET
var dealer_cards_root: Node3D
var player_cards_root: Node3D
var status_label: Label3D
var dealer_score_label: Label3D
var player_score_label: Label3D
var message_label: Label3D
var relics_label: Label3D
var buttons: Dictionary = {}


func _ready() -> void:
	add_child(run_manager)
	_build_world()
	_update_view()


func _build_world() -> void:
	_add_camera()
	_add_lights()
	_add_table()
	_add_labels()
	_add_buttons()

	dealer_cards_root = Node3D.new()
	dealer_cards_root.position = Vector3(0.0, CARD_Y, -1.35)
	add_child(dealer_cards_root)

	player_cards_root = Node3D.new()
	player_cards_root.position = Vector3(0.0, CARD_Y, 1.30)
	add_child(player_cards_root)


func _add_camera() -> void:
	var camera := Camera3D.new()
	camera.name = "StaticCamera"
	camera.position = Vector3(0.0, 5.8, 5.6)
	camera.rotation_degrees = Vector3(-52.0, 0.0, 0.0)
	camera.fov = 42.0
	camera.current = true
	add_child(camera)


func _add_lights() -> void:
	var world := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.015, 0.012, 0.010)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.28, 0.22, 0.16)
	environment.ambient_light_energy = 0.6
	world.environment = environment
	add_child(world)

	var key_light := DirectionalLight3D.new()
	key_light.rotation_degrees = Vector3(-58.0, -28.0, 0.0)
	key_light.light_energy = 2.4
	key_light.shadow_enabled = true
	add_child(key_light)

	var warm_light := OmniLight3D.new()
	warm_light.position = Vector3(0.0, 3.2, 1.8)
	warm_light.light_color = Color(1.0, 0.72, 0.42)
	warm_light.light_energy = 1.6
	warm_light.omni_range = 7.0
	add_child(warm_light)


func _add_table() -> void:
	var table := MeshInstance3D.new()
	var mesh := PlaneMesh.new()
	mesh.size = Vector2(10.8, 6.2)
	table.mesh = mesh
	table.material_override = _make_texture_material(TABLE_TEXTURE)
	add_child(table)

	var rim := MeshInstance3D.new()
	var rim_mesh := BoxMesh.new()
	rim_mesh.size = Vector3(11.2, 0.16, 6.6)
	rim.mesh = rim_mesh
	rim.position = Vector3(0.0, -0.10, 0.0)
	rim.material_override = _make_color_material(Color(0.08, 0.035, 0.018))
	add_child(rim)


func _add_labels() -> void:
	status_label = _create_label(Vector3(-4.55, 0.18, -2.70), 30)
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	add_child(status_label)

	dealer_score_label = _create_label(Vector3(3.65, 0.18, -2.05), 24)
	add_child(dealer_score_label)

	player_score_label = _create_label(Vector3(3.65, 0.18, 0.72), 24)
	add_child(player_score_label)

	message_label = _create_label(Vector3(0.0, 0.20, 0.0), 25)
	add_child(message_label)

	relics_label = _create_label(Vector3(4.10, 0.18, 2.75), 17)
	add_child(relics_label)

	var dealer_title := _create_label(Vector3(-4.25, 0.18, -2.05), 24)
	dealer_title.text = "Dealer"
	dealer_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	add_child(dealer_title)

	var player_title := _create_label(Vector3(-4.25, 0.18, 0.72), 24)
	player_title.text = "Player"
	player_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	add_child(player_title)


func _add_buttons() -> void:
	_add_button("bet_down", "-5", Vector3(-2.75, 0.18, 2.72), Vector2(0.62, 0.38))
	_add_button("bet_up", "+5", Vector3(-2.05, 0.18, 2.72), Vector2(0.62, 0.38))
	_add_button("max_bet", "Max", Vector3(-1.25, 0.18, 2.72), Vector2(0.78, 0.38))
	_add_button("deal", "Deal", Vector3(-0.20, 0.18, 2.72), Vector2(0.90, 0.42))
	_add_button("hit", "Hit", Vector3(0.82, 0.18, 2.72), Vector2(0.90, 0.42))
	_add_button("stand", "Stand", Vector3(1.84, 0.18, 2.72), Vector2(0.94, 0.42))
	_add_button("retry", "Retry", Vector3(2.92, 0.18, 2.72), Vector2(0.94, 0.42))


func _add_button(action: String, text: String, position: Vector3, size: Vector2) -> void:
	var root := Node3D.new()
	root.position = position
	add_child(root)

	var mesh_instance := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(size.x, 0.08, size.y)
	mesh_instance.mesh = box
	mesh_instance.material_override = _make_color_material(Color(0.18, 0.09, 0.045))
	root.add_child(mesh_instance)

	var area := Area3D.new()
	var shape := CollisionShape3D.new()
	var box_shape := BoxShape3D.new()
	box_shape.size = Vector3(size.x, 0.18, size.y)
	shape.shape = box_shape
	area.add_child(shape)
	area.input_event.connect(_on_button_input.bind(action))
	root.add_child(area)

	var label := _create_label(Vector3(0.0, 0.10, 0.0), 16)
	label.text = text
	root.add_child(label)

	buttons[action] = {
		"root": root,
		"mesh": mesh_instance,
		"label": label,
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
		message_label.text = "Cannot start hand."
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
		message_label.text += " Stage cleared."
	elif run_manager.is_game_over():
		message_label.text += " Game over."


func _update_view() -> void:
	status_label.text = "Debt to the House\nStage %d | Money $%d | Bet $%d | Debt $%d | Hands %d" % [
		run_manager.stage,
		run_manager.money,
		bet,
		run_manager.debt_target,
		run_manager.hands_left,
	]

	var player_value := engine.player_hand.get_value(engine.rules) if not engine.player_hand.cards.is_empty() else 0
	var dealer_value := engine.dealer_hand.get_value(engine.rules) if not engine.dealer_hand.cards.is_empty() else 0
	player_score_label.text = "Score %d" % player_value if player_value > 0 else "Score -"
	dealer_score_label.text = "Score ?" if engine.is_round_active and engine.dealer_hand.cards.size() > 1 else ("Score %d" % dealer_value if dealer_value > 0 else "Score -")
	relics_label.text = "Relics %d" % run_manager.relics.size()

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
		card_node.position = Vector3(start_x + index * CARD_SPACING, index * 0.012, 0.0)
		card_node.rotation_degrees = Vector3(0.0, randf_range(-2.2, 2.2), 0.0)
		root.add_child(card_node)


func _create_card_3d(card: CardData, hidden: bool) -> Node3D:
	var root := Node3D.new()

	var shadow := MeshInstance3D.new()
	var shadow_mesh := PlaneMesh.new()
	shadow_mesh.size = CARD_SIZE
	shadow.mesh = shadow_mesh
	shadow.position = Vector3(0.035, -0.012, 0.045)
	shadow.material_override = _make_color_material(Color(0.0, 0.0, 0.0, 0.35))
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

	var top := _create_label(Vector3(-0.25, 0.045, -0.35), 14)
	top.text = "%s\n%s" % [card.rank, suit]
	top.modulate = color
	root.add_child(top)

	var center := _create_label(Vector3(0.0, 0.05, 0.02), 34)
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
	mesh.transparency = 0.0 if enabled else 0.45
	label.modulate = Color.WHITE if enabled else Color(0.45, 0.40, 0.35)


func _create_label(position: Vector3, font_size: int) -> Label3D:
	var label := Label3D.new()
	label.position = position
	label.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.font_size = font_size
	label.modulate = Color(0.96, 0.90, 0.78)
	label.outline_size = 6
	label.outline_modulate = Color(0.02, 0.015, 0.01, 0.9)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return label


func _make_texture_material(texture: Texture2D) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_texture = texture
	material.roughness = 0.72
	material.metallic = 0.0
	return material


func _make_color_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.85
	return material


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
			return "Player wins."
		BlackjackResult.DEALER_WIN:
			return "Dealer wins."
		BlackjackResult.PUSH:
			return "Push."
		BlackjackResult.PLAYER_BUST:
			return "Player busts."
		BlackjackResult.DEALER_BUST:
			return "Dealer busts."
	return "Round resolved."
