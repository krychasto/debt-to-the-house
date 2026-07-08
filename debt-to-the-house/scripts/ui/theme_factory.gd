extends RefCounted
class_name ThemeFactory

const BACKGROUND := Color(0.010, 0.012, 0.030)
const BACKGROUND_TOP := Color(0.020, 0.005, 0.020)
const BACKGROUND_BOTTOM := Color(0.000, 0.020, 0.030)
const TABLE_GREEN := Color(0.015, 0.145, 0.090)
const TABLE_GREEN_DARK := Color(0.006, 0.070, 0.050)
const PANEL_DARK := Color(0.035, 0.012, 0.030)
const PANEL_DARKER := Color(0.016, 0.006, 0.018)
const GOLD := Color(1.000, 0.720, 0.190)
const GOLD_SOFT := Color(1.000, 0.865, 0.430)
const CASINO_RED := Color(0.430, 0.035, 0.070)
const DANGER_RED := Color(1.000, 0.075, 0.180)
const NEON_CYAN := Color(0.160, 0.960, 0.900)
const TEXT_CREAM := Color(1.000, 0.940, 0.790)
const TEXT_MUTED := Color(0.760, 0.720, 0.640)
const INK := Color(0.020, 0.006, 0.012)
const CARD_FACE := Color(0.955, 0.875, 0.650)
const CARD_FACE_LIGHT := Color(1.000, 0.945, 0.760)
const CARD_SHADOW := Color(0.000, 0.000, 0.000, 0.440)


static func make_style(bg_color: Color, border_color: Color = Color.TRANSPARENT, border_width: int = 0, radius: int = 8, shadow_color: Color = Color.TRANSPARENT, shadow_size: int = 0) -> StyleBoxFlat:
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
	style.content_margin_left = 10
	style.content_margin_top = 8
	style.content_margin_right = 10
	style.content_margin_bottom = 8
	style.shadow_color = shadow_color
	style.shadow_size = shadow_size
	style.shadow_offset = Vector2(0.0, 3.0)
	return style


static func background_gradient() -> GradientTexture2D:
	var gradient := Gradient.new()
	gradient.set_color(0, BACKGROUND_TOP)
	gradient.set_color(1, BACKGROUND_BOTTOM)

	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill = GradientTexture2D.FILL_LINEAR
	texture.fill_from = Vector2(0.0, 0.0)
	texture.fill_to = Vector2(1.0, 1.0)
	return texture


static func table_style() -> StyleBoxFlat:
	return make_style(TABLE_GREEN, GOLD, 2, 22, Color(0.0, 0.0, 0.0, 0.45), 18)


static func hand_zone_style(is_dealer: bool) -> StyleBoxFlat:
	var accent := NEON_CYAN if is_dealer else GOLD
	return make_style(Color(TABLE_GREEN_DARK.r, TABLE_GREEN_DARK.g, TABLE_GREEN_DARK.b, 0.42), Color(accent.r, accent.g, accent.b, 0.42), 1, 16, Color(0.0, 0.0, 0.0, 0.22), 6)


static func hud_panel_style() -> StyleBoxFlat:
	return make_style(Color(PANEL_DARK.r, PANEL_DARK.g, PANEL_DARK.b, 0.88), GOLD, 1, 12, Color(0.0, 0.0, 0.0, 0.38), 10)


static func stat_card_style(accent_color: Color) -> StyleBoxFlat:
	return make_style(Color(PANEL_DARKER.r, PANEL_DARKER.g, PANEL_DARKER.b, 0.88), accent_color, 1, 10, Color(accent_color.r, accent_color.g, accent_color.b, 0.20), 8)


static func message_style() -> StyleBoxFlat:
	return make_style(Color(PANEL_DARK.r, PANEL_DARK.g, PANEL_DARK.b, 0.78), Color(GOLD.r, GOLD.g, GOLD.b, 0.82), 1, 12, Color(0.0, 0.0, 0.0, 0.34), 8)


static func controls_style() -> StyleBoxFlat:
	return make_style(Color(PANEL_DARK.r, PANEL_DARK.g, PANEL_DARK.b, 0.88), Color(GOLD.r, GOLD.g, GOLD.b, 0.68), 1, 12, Color(0.0, 0.0, 0.0, 0.36), 10)


static func button_style(bg_color: Color, accent_color: Color, state: String = "normal") -> StyleBoxFlat:
	match state:
		"hover":
			return make_style(bg_color.lightened(0.10), accent_color.lightened(0.18), 2, 10, Color(accent_color.r, accent_color.g, accent_color.b, 0.32), 10)
		"pressed":
			return make_style(bg_color.darkened(0.10), GOLD_SOFT, 1, 10, Color(0.0, 0.0, 0.0, 0.30), 5)
		"disabled":
			return make_style(Color(0.075, 0.070, 0.080, 0.52), Color(0.350, 0.340, 0.360, 0.35), 1, 10, Color.TRANSPARENT, 0)

	return make_style(bg_color, Color(accent_color.r, accent_color.g, accent_color.b, 0.86), 1, 10, Color(0.0, 0.0, 0.0, 0.30), 7)


static func card_face_style() -> StyleBoxFlat:
	return make_style(CARD_FACE, GOLD, 1, 8, CARD_SHADOW, 8)


static func card_inner_style() -> StyleBoxFlat:
	return make_style(CARD_FACE_LIGHT, Color(0.360, 0.155, 0.045, 0.58), 1, 5, Color.TRANSPARENT, 0)


static func card_back_style() -> StyleBoxFlat:
	return make_style(Color(0.120, 0.020, 0.040), GOLD, 2, 8, CARD_SHADOW, 8)


static func relic_card_style(rarity: String, alpha: float = 1.0) -> StyleBoxFlat:
	var color := rarity_color(rarity)
	var width := 1
	if rarity == "rare":
		width = 2
	elif rarity == "epic" or rarity == "legendary":
		width = 3

	return make_style(Color(PANEL_DARK.r, PANEL_DARK.g, PANEL_DARK.b, 0.88 * alpha), color, width, 12, Color(color.r, color.g, color.b, 0.30 * alpha), 10 + int(rarity_intensity(rarity) * 10.0))


static func reward_overlay_color() -> Color:
	return Color(0.005, 0.000, 0.012, 0.82)


static func rarity_color(rarity: String) -> Color:
	match rarity:
		"uncommon":
			return Color(0.300, 1.000, 0.520, 0.78)
		"rare":
			return Color(0.180, 0.610, 1.000, 0.86)
		"epic":
			return Color(0.760, 0.320, 1.000, 0.90)
		"legendary":
			return Color(1.000, 0.740, 0.150, 0.96)

	return Color(0.760, 0.760, 0.720, 0.62)


static func rarity_intensity(rarity: String) -> float:
	match rarity:
		"uncommon":
			return 0.35
		"rare":
			return 0.65
		"epic":
			return 0.92
		"legendary":
			return 1.30

	return 0.16
