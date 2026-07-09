extends Button
class_name TableItem

signal tooltip_requested(item: TableItem)
signal tooltip_hidden

var id: String = ""
var display_name: String = ""
var description: String = ""
var effect_text: String = ""
var scene: PackedScene
var slot_type: String = TableItemSlot.CENTER_LEFT
var idle_animation: String = "float"
var activation_animation: String = "pop"
var rarity: String = RelicData.RARITY_COMMON
var relic_id: String = ""

var _visual_root: Control
var _accent: Color = Color.WHITE
var _item_tint: Color = Color.WHITE
var _base_scale := Vector2.ONE


func setup(data: Dictionary, relic: RelicData) -> void:
	id = String(data.get("id", ""))
	display_name = String(data.get("display_name", id))
	description = String(data.get("description", ""))
	effect_text = relic.description if relic != null else String(data.get("effect_text", ""))
	scene = data.get("scene", null)
	slot_type = String(data.get("slot_type", TableItemSlot.CENTER_LEFT))
	idle_animation = String(data.get("idle_animation", "float"))
	activation_animation = String(data.get("activation_animation", "pop"))
	rarity = String(data.get("rarity", relic.rarity if relic != null else RelicData.RARITY_COMMON))
	relic_id = relic.id if relic != null else ""
	_accent = _get_rarity_color(rarity)
	_item_tint = data.get("accent", _accent)

	text = ""
	tooltip_text = ""
	custom_minimum_size = Vector2(66, 66)
	focus_mode = Control.FOCUS_NONE
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_placeholder(data)
	_apply_button_shell()

	if not pressed.is_connected(_on_pressed):
		pressed.connect(_on_pressed)
	if not mouse_entered.is_connected(_on_mouse_entered):
		mouse_entered.connect(_on_mouse_entered)
	if not mouse_exited.is_connected(_on_mouse_exited):
		mouse_exited.connect(_on_mouse_exited)


func play_spawn_animation() -> void:
	scale = _base_scale * 0.2
	modulate = Color(1.0, 1.0, 1.0, 0.0)
	pivot_offset = size * 0.5

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", _base_scale, 0.24).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 1.0, 0.14)
	tween.chain().tween_callback(play_activation_animation)
	tween.chain().tween_callback(play_idle_animation)


func play_idle_animation() -> void:
	if not is_inside_tree():
		return

	match idle_animation:
		"rotate":
			_play_rotate_idle()
		"sway":
			_play_sway_idle()
		"blink":
			_play_blink_idle()
		"projector":
			_play_projector_idle()
		_:
			_play_float_idle()


func play_activation_animation() -> void:
	pivot_offset = size * 0.5
	match activation_animation:
		"spin":
			var tween := create_tween()
			tween.set_parallel(true)
			tween.tween_property(self, "rotation_degrees", rotation_degrees + 360.0, 0.34).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			tween.tween_property(self, "scale", _base_scale * 1.14, 0.10)
			tween.chain().tween_property(self, "scale", _base_scale, 0.12)
		"flash":
			_flash_accent()
		_:
			var tween := create_tween()
			tween.tween_property(self, "scale", _base_scale * 1.16, 0.10).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			tween.tween_property(self, "scale", _base_scale, 0.14).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func set_display_scale(value: float) -> void:
	_base_scale = Vector2(value, value)
	scale = _base_scale


func _build_placeholder(data: Dictionary) -> void:
	_clear_children()
	_visual_root = Control.new()
	_visual_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_visual_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_visual_root)

	match String(data.get("shape", "card")):
		"coin":
			_add_circle(Vector2(33, 33), 23.0, _accent, "$")
		"flask":
			_add_box(Vector2(18, 10), Vector2(30, 48), _accent, "♜", _item_tint)
		"dice":
			_add_box(Vector2(10, 18), Vector2(25, 25), _accent, "⚂", _item_tint)
			_add_box(Vector2(32, 24), Vector2(25, 25), _accent, "⚄", _item_tint.lightened(0.12))
		"eye":
			_add_box(Vector2(8, 21), Vector2(50, 24), _accent, "◉", _item_tint)
		"clock":
			_add_circle(Vector2(33, 33), 24.0, _accent, "◷")
		"projector":
			_add_box(Vector2(13, 36), Vector2(40, 22), _accent, "▱", _item_tint)
			_add_hologram()
		_:
			_add_box(Vector2(14, 8), Vector2(38, 52), _accent, "A")


func _add_box(position: Vector2, size_value: Vector2, color: Color, label_text: String, fill_color: Color = Color.TRANSPARENT) -> void:
	var fill := fill_color if fill_color != Color.TRANSPARENT else color
	var panel := PanelContainer.new()
	panel.position = position
	panel.custom_minimum_size = size_value
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel", _make_style(Color(fill.r * 0.16, fill.g * 0.16, fill.b * 0.16, 0.84), color, 2, 6))
	_visual_root.add_child(panel)

	var label := Label.new()
	label.text = label_text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", color.lightened(0.28))
	label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.85))
	label.add_theme_constant_override("outline_size", 3)
	panel.add_child(label)


func _add_circle(center: Vector2, radius: float, color: Color, label_text: String) -> void:
	var panel := PanelContainer.new()
	panel.position = center - Vector2(radius, radius)
	panel.custom_minimum_size = Vector2(radius * 2.0, radius * 2.0)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel", _make_style(Color(_item_tint.r * 0.18, _item_tint.g * 0.18, _item_tint.b * 0.18, 0.90), color, 2, int(radius)))
	_visual_root.add_child(panel)

	var label := Label.new()
	label.text = label_text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", color.lightened(0.25))
	label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.88))
	label.add_theme_constant_override("outline_size", 3)
	panel.add_child(label)


func _add_hologram() -> void:
	var glow := ColorRect.new()
	glow.position = Vector2(23, 9)
	glow.custom_minimum_size = Vector2(20, 28)
	glow.color = Color(_accent.r, _accent.g, _accent.b, 0.36)
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_visual_root.add_child(glow)


func _apply_button_shell() -> void:
	var empty := StyleBoxFlat.new()
	empty.bg_color = Color.TRANSPARENT
	empty.border_width_left = 0
	empty.border_width_right = 0
	empty.border_width_top = 0
	empty.border_width_bottom = 0
	add_theme_stylebox_override("normal", empty)
	add_theme_stylebox_override("hover", empty)
	add_theme_stylebox_override("pressed", empty)
	add_theme_stylebox_override("disabled", empty)


func _play_float_idle() -> void:
	var tween := create_tween().set_loops()
	tween.tween_property(self, "position:y", position.y - 4.0, 1.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "position:y", position.y, 1.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _play_rotate_idle() -> void:
	var tween := create_tween().set_loops()
	tween.tween_property(self, "rotation_degrees", rotation_degrees + 360.0, 3.8).set_trans(Tween.TRANS_LINEAR)


func _play_sway_idle() -> void:
	var tween := create_tween().set_loops()
	tween.tween_property(self, "rotation_degrees", -5.0, 1.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "rotation_degrees", 5.0, 1.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _play_blink_idle() -> void:
	var tween := create_tween().set_loops()
	tween.tween_interval(1.2)
	tween.tween_property(self, "modulate", Color(1.0, 0.30, 0.36, 0.82), 0.08)
	tween.tween_property(self, "modulate", Color.WHITE, 0.14)


func _play_projector_idle() -> void:
	var tween := create_tween().set_loops()
	tween.tween_property(self, "modulate:a", 0.62, 0.36)
	tween.tween_property(self, "modulate:a", 1.0, 0.42)


func _flash_accent() -> void:
	modulate = Color(_accent.r, _accent.g, _accent.b, 1.0)
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.22)


func _on_pressed() -> void:
	play_activation_animation()
	tooltip_requested.emit(self)


func _on_mouse_entered() -> void:
	pivot_offset = size * 0.5
	var tween := create_tween()
	tween.tween_property(self, "scale", _base_scale * 1.08, 0.10)
	tooltip_requested.emit(self)


func _on_mouse_exited() -> void:
	var tween := create_tween()
	tween.tween_property(self, "scale", _base_scale, 0.10)
	tooltip_hidden.emit()


func _make_style(bg: Color, border: Color, border_width: int, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.shadow_color = Color(border.r, border.g, border.b, 0.22)
	style.shadow_size = 8
	return style


func _get_rarity_color(value: String) -> Color:
	match value:
		RelicData.RARITY_UNCOMMON:
			return Color(0.34, 1.0, 0.60)
		RelicData.RARITY_RARE:
			return Color(0.18, 0.64, 1.0)
		RelicData.RARITY_EPIC:
			return Color(0.78, 0.36, 1.0)
		RelicData.RARITY_LEGENDARY:
			return Color(1.0, 0.78, 0.16)
		_:
			return Color(0.82, 0.86, 0.90)


func _clear_children() -> void:
	for child: Node in get_children():
		child.queue_free()
