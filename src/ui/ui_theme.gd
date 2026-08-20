class_name UiTheme
extends RefCounted

## Shared visual theme for M3.5 node-based UI. Presentation only.

const BG := Color("07111d")
const PANEL := Color("13283a")
const PANEL_BORDER := Color("8fd7cf")
const TEXT := Color("dceaf7")
const TEXT_DIM := Color("9db1c4")
const ACCENT := Color("f5cf72")
const ACCENT_GOOD := Color("6ff0aa")
const ACCENT_BAD := Color("ff7a7a")
const DISABLED := Color("44515e")
const DISABLED_TEXT := Color("657383")


static func panel_style(border: Color = PANEL_BORDER, fill: Color = PANEL) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	style.set_content_margin_all(12)
	return style


static func button_style(enabled_color: Color = Color("214157"), disabled_color: Color = Color("17212b")) -> Dictionary:
	var normal := StyleBoxFlat.new()
	normal.bg_color = enabled_color
	normal.set_corner_radius_all(6)
	normal.set_content_margin_all(10)
	normal.border_color = Color("8fd7cf")
	normal.set_border_width_all(2)
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color("2b5870")
	var pressed := normal.duplicate() as StyleBoxFlat
	pressed.bg_color = Color("0f2a38")
	var disabled := normal.duplicate() as StyleBoxFlat
	disabled.bg_color = disabled_color
	disabled.border_color = DISABLED
	return {"normal": normal, "hover": hover, "pressed": pressed, "disabled": disabled, "focus": normal}


static func make_button(text: String, font_size: int = 16) -> Button:
	var button := Button.new()
	button.text = text
	button.add_theme_font_size_override("font_size", font_size)
	button.add_theme_color_override("font_color", TEXT)
	button.add_theme_color_override("font_hover_color", TEXT)
	button.add_theme_color_override("font_pressed_color", TEXT)
	button.add_theme_color_override("font_disabled_color", DISABLED_TEXT)
	button.add_theme_color_override("font_focus_color", TEXT)
	var styles := button_style()
	button.add_theme_stylebox_override("normal", styles.normal)
	button.add_theme_stylebox_override("hover", styles.hover)
	button.add_theme_stylebox_override("pressed", styles.pressed)
	button.add_theme_stylebox_override("disabled", styles.disabled)
	button.add_theme_stylebox_override("focus", styles.focus)
	return button


static func make_label(text: String, font_size: int = 16, color: Color = TEXT) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label


static func make_panel(fill: Color = PANEL, border: Color = PANEL_BORDER) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", panel_style(border, fill))
	return panel


static func make_modal_overlay() -> ColorRect:
	var overlay := ColorRect.new()
	overlay.color = Color(0.02, 0.04, 0.07, 0.72)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	return overlay
