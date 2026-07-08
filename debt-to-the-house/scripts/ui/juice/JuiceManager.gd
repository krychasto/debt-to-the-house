extends RefCounted
class_name JuiceManager


static func play_screen_shake(root: Control, strength: float = 10.0, duration: float = 0.24) -> void:
	JuiceShake.screen_shake(root, strength, duration)


static func play_camera_shake(camera: Camera2D, strength: float = 8.0, duration: float = 0.22) -> void:
	JuiceShake.camera_shake(camera, strength, duration)


static func play_button_bounce(button: Button) -> void:
	JuiceAnimationLibrary.button_bounce(button)
	JuiceSoundController.play_ui_click(button)


static func wire_button(button: Button) -> void:
	if not is_instance_valid(button):
		return

	button.mouse_entered.connect(func() -> void:
		JuiceAnimationLibrary.button_hover(button, true)
	)
	button.mouse_exited.connect(func() -> void:
		JuiceAnimationLibrary.button_hover(button, false)
	)
	button.button_down.connect(func() -> void:
		if not button.disabled:
			button.pivot_offset = button.size * 0.5
			var tween := button.create_tween()
			tween.tween_property(button, "scale", Vector2(0.96, 0.96), 0.05)
	)
	button.button_up.connect(func() -> void:
		play_button_bounce(button)
	)


static func play_card_draw(card: Control, deck_global_position: Vector2, final_global_position: Vector2, final_rotation: float, delay: float = 0.0) -> void:
	JuiceAnimationLibrary.card_draw(card, deck_global_position, final_global_position, final_rotation, delay)
	JuiceSoundController.play_card(card)


static func play_card_bounce(card: Control) -> void:
	JuiceAnimationLibrary.card_bounce(card)


static func play_hover_effect(card: Control, is_hovered: bool, offset: Vector2 = Vector2(0.0, -8.0)) -> void:
	JuiceAnimationLibrary.hover_lift(card, is_hovered, offset)


static func play_reveal_animation(card: Control) -> void:
	JuiceAnimationLibrary.reveal(card)


static func play_flip_animation(card: Control) -> void:
	JuiceAnimationLibrary.flip(card)


static func play_relic_reveal(relic_node: Control) -> void:
	JuiceGlowController.glow_card(relic_node, Color(0.78, 0.38, 1.0, 0.45), 0.34)
	JuiceTweenFactory.pop_in(relic_node, 0.22)


static func play_relic_rarity_reveal(root: Control, relic_node: Control, rarity: String, flash_overlay: ColorRect = null) -> void:
	if not is_instance_valid(relic_node):
		return

	var color := get_rarity_color(rarity)
	var intensity := get_rarity_intensity(rarity)
	JuiceGlowController.glow_card(relic_node, color, 0.28 + intensity * 0.10)
	JuiceTweenFactory.pop_in(relic_node, 0.18 + intensity * 0.04)
	pulse_label(relic_node, 1.04 + intensity * 0.04, 0.18 + intensity * 0.05)

	if rarity == "rare" or rarity == "epic" or rarity == "legendary":
		JuiceParticleSpawner.spawn_burst(root, relic_node.get_global_rect().get_center(), color, 8 + int(intensity * 8.0), 38.0 + intensity * 22.0)

	if rarity == "epic" or rarity == "legendary":
		JuiceShake.shake_node(relic_node, 2.5 + intensity * 2.0, 0.16)

	if rarity == "legendary" and is_instance_valid(flash_overlay):
		flash_overlay.modulate = Color(color.r, color.g, color.b, 0.30)
		JuiceTweenFactory.fade_to(flash_overlay, 0.0, 0.34)
		JuiceShake.screen_shake(root, 7.0, 0.22)


static func play_relic_selected(root: Control, selected: Control, dismissed: Array[Control], message_label: Label = null) -> void:
	if is_instance_valid(selected):
		pulse_label(selected, 1.18, 0.24)
		JuiceGlowController.glow_card(selected, Color(1.0, 0.82, 0.18, 0.58), 0.42)
		JuiceParticleSpawner.spawn_burst(root, selected.get_global_rect().get_center(), Color(1.0, 0.82, 0.18, 0.80), 18, 70.0)

	for node: Control in dismissed:
		if not is_instance_valid(node):
			continue
		var direction := -1.0 if node.global_position.x < selected.global_position.x else 1.0
		var tween := node.create_tween()
		tween.set_parallel(true)
		tween.tween_property(node, "modulate:a", 0.18, 0.20)
		tween.tween_property(node, "position", node.position + Vector2(42.0 * direction, 18.0), 0.24).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		tween.tween_property(node, "scale", Vector2(0.88, 0.88), 0.20)

	if is_instance_valid(message_label):
		message_label.text = "RELIKT ZDOBYTY"
		message_label.visible = true
		pulse_label(message_label, 1.16, 0.22)


static func play_reward_anticipation(panel: Control) -> void:
	JuiceAnimationLibrary.reward_anticipation(panel)


static func play_success_flash(target: CanvasItem) -> void:
	JuiceGlowController.success_flash(target)


static func play_failure_flash(target: CanvasItem) -> void:
	JuiceGlowController.failure_flash(target)


static func play_money_popup(parent: Control, anchor: Control, amount: int) -> void:
	JuicePopupSpawner.spawn_money_popup(parent, anchor, amount)


static func play_token_popup(parent: Control, anchor: Control, amount: int) -> void:
	JuicePopupSpawner.spawn_token_popup(parent, anchor, amount)


static func play_combo_popup(parent: Control, text: String, global_position: Vector2) -> void:
	JuicePopupSpawner.spawn_combo_popup(parent, text, global_position)


static func pulse_label(label: Control, scale_amount: float = 1.08, duration: float = 0.18) -> void:
	JuiceTweenFactory.pulse(label, scale_amount, duration)


static func play_blackjack(root: Control, banner: Label, money_label: Control, debt_label: Control, flash_overlay: ColorRect, payout: int) -> void:
	play_success_flash(flash_overlay)
	show_result_banner(banner, "BLACKJACK! +$%d" % payout, ThemeFactory.GOLD_SOFT, 1.30)
	JuiceShake.shake_node(banner, 8.0, 0.18)
	JuiceGlowController.success_flash(money_label)
	pulse_label(money_label, 1.18, 0.22)
	pulse_label(debt_label, 1.14, 0.20)
	JuiceParticleSpawner.spawn_burst(root, banner.get_global_rect().get_center(), Color(1.0, 0.82, 0.18, 0.86), 18, 76.0)
	JuiceSoundController.play_success(root)


static func play_round_win(root: Control, banner: Label, money_label: Control, flash_overlay: ColorRect, payout: int) -> void:
	flash_overlay.modulate = Color(0.16, 0.94, 0.52, 0.22)
	JuiceTweenFactory.fade_to(flash_overlay, 0.0, 0.30)
	show_result_banner(banner, "WYGRANA +$%d" % payout, Color(0.68, 1.0, 0.48), 1.0)
	pulse_label(money_label, 1.12, 0.18)
	JuiceParticleSpawner.spawn_burst(root, banner.get_global_rect().get_center(), Color(0.20, 1.0, 0.84, 0.78), 12, 56.0)


static func play_round_push(banner: Label, flash_overlay: ColorRect) -> void:
	flash_overlay.modulate = Color(0.42, 0.58, 0.86, 0.16)
	JuiceTweenFactory.fade_to(flash_overlay, 0.0, 0.30)
	show_result_banner(banner, "REMIS", Color(0.72, 0.82, 0.96), 0.92)


static func play_round_loss(banner: Label, message_label: Control, flash_overlay: ColorRect, text: String) -> void:
	flash_overlay.modulate = Color(ThemeFactory.DANGER_RED.r, ThemeFactory.DANGER_RED.g, ThemeFactory.DANGER_RED.b, 0.26)
	JuiceTweenFactory.fade_to(flash_overlay, 0.0, 0.30)
	show_result_banner(banner, text, ThemeFactory.DANGER_RED, 1.0)
	JuiceShake.shake_node(message_label, 7.0, 0.22)


static func play_stage_success(root: Control, banner: Label, money_label: Control, debt_label: Control, flash_overlay: ColorRect) -> void:
	pulse_label(money_label, 1.22, 0.26)
	pulse_label(debt_label, 1.24, 0.28)
	flash_overlay.modulate = Color(1.0, 0.82, 0.18, 0.30)
	JuiceTweenFactory.fade_to(flash_overlay, 0.0, 0.34)
	show_result_banner(banner, "DŁUG SPŁACONY", Color(1.0, 0.78, 0.16), 1.18)
	JuiceParticleSpawner.spawn_burst(root, banner.get_global_rect().get_center(), Color(1.0, 0.82, 0.18, 0.86), 22, 86.0)


static func play_failure(root: Control, table_root: Control, banner: Label, message_label: Control, shade: ColorRect) -> void:
	JuiceShake.screen_shake(table_root, 11.0, 0.28)
	JuiceShake.shake_node(message_label, 9.0, 0.25)
	show_result_banner(banner, "KASYNO WYGRYWA", Color(1.0, 0.18, 0.55), 1.04)
	if is_instance_valid(shade):
		shade.color = Color(0.02, 0.00, 0.03, 0.34)
	JuiceParticleSpawner.spawn_burst(root, banner.get_global_rect().get_center(), Color(1.0, 0.18, 0.36, 0.60), 10, 52.0)
	JuiceSoundController.play_failure(root)


static func show_result_banner(banner: Label, text: String, color: Color, intensity: float = 1.0) -> void:
	if not is_instance_valid(banner):
		return

	banner.text = text
	banner.add_theme_font_size_override("font_size", int(52.0 * intensity))
	banner.add_theme_color_override("font_outline_color", ThemeFactory.INK)
	banner.add_theme_constant_override("outline_size", int(10.0 * intensity))
	banner.visible = true
	banner.pivot_offset = banner.size * 0.5
	banner.position = Vector2(0.0, 18.0)
	banner.scale = Vector2(0.62, 0.62)
	banner.modulate = Color(color.r, color.g, color.b, 0.0)

	var tween := banner.create_tween()
	tween.set_parallel(true)
	tween.tween_property(banner, "position", Vector2.ZERO, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(banner, "scale", Vector2.ONE * intensity, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(banner, "modulate:a", 1.0, 0.08)
	tween.chain().tween_interval(0.48)
	tween.chain().tween_property(banner, "modulate:a", 0.0, 0.22).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_callback(func() -> void:
		if is_instance_valid(banner):
			banner.visible = false
			banner.scale = Vector2.ONE
	)


static func get_rarity_color(rarity: String) -> Color:
	return ThemeFactory.rarity_color(rarity)


static func get_rarity_intensity(rarity: String) -> float:
	return ThemeFactory.rarity_intensity(rarity)
