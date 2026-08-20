class_name HudPanel
extends PanelContainer

## Right-side HUD: scores, hand slots, combo, badges, tools and action buttons.
## Presentation only; it renders a view-model and emits command requests.

signal settle_requested
signal keep_requested
signal reset_requested
signal tool_requested
signal pause_requested
signal badge_requested

var target_label: Label
var score_label: Label
var strokes_label: Label
var hand_label: Label
var slot_boxes: Array[PanelContainer] = []
var slot_labels: Array[Label] = []
var slot_caption_labels: Array[Label] = []
var combo_label: Label
var formula_label: Label
var badges_label: Label
var tools_label: Label
var phase_label: Label
var power_label: Label
var settle_button: Button
var keep_button: Button
var reset_button: Button
var tool_button: Button
var pause_button: Button


func _init() -> void:
	custom_minimum_size = Vector2(300, 0)
	add_theme_stylebox_override("panel", UiTheme.panel_style())
	_build()


func _build() -> void:
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 8)
	margin.add_child(column)

	column.add_child(UiTheme.make_label(LocalizationZhCn.text("game.title"), 20, UiTheme.ACCENT))

	target_label = UiTheme.make_label("", 16, UiTheme.TEXT_DIM)
	score_label = UiTheme.make_label("", 26, UiTheme.ACCENT)
	strokes_label = UiTheme.make_label("", 16, UiTheme.TEXT)
	hand_label = UiTheme.make_label("", 15, UiTheme.ACCENT_GOOD)
	column.add_child(target_label)
	column.add_child(score_label)
	column.add_child(strokes_label)
	column.add_child(hand_label)

	# Hand slots: 3 + 2 grid
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 6)
	column.add_child(grid)
	for index in 5:
		var box := PanelContainer.new()
		box.custom_minimum_size = Vector2(82, 58)
		box.add_theme_stylebox_override("panel", UiTheme.panel_style(UiTheme.TEXT_DIM, Color("132334")))
		var inner := VBoxContainer.new()
		inner.add_theme_constant_override("separation", 0)
		box.add_child(inner)
		var slot_label := UiTheme.make_label("", 15, UiTheme.TEXT)
		slot_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var caption := UiTheme.make_label("", 9, UiTheme.TEXT_DIM)
		caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		inner.add_child(slot_label)
		inner.add_child(caption)
		grid.add_child(box)
		slot_boxes.append(box)
		slot_labels.append(slot_label)
		slot_caption_labels.append(caption)

	combo_label = UiTheme.make_label("", 15, UiTheme.TEXT)
	formula_label = UiTheme.make_label("", 19, UiTheme.ACCENT)
	column.add_child(combo_label)
	column.add_child(formula_label)

	badges_label = UiTheme.make_label("", 11, UiTheme.ACCENT)
	badges_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	badges_label.custom_minimum_size = Vector2(0, 34)
	column.add_child(badges_label)

	tools_label = UiTheme.make_label("", 11, UiTheme.ACCENT_GOOD)
	tools_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tools_label.custom_minimum_size = Vector2(0, 30)
	column.add_child(tools_label)

	phase_label = UiTheme.make_label("", 12, UiTheme.TEXT_DIM)
	power_label = UiTheme.make_label("", 12, UiTheme.TEXT_DIM)
	column.add_child(phase_label)
	column.add_child(power_label)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 4)
	column.add_child(spacer)

	var action_row := HBoxContainer.new()
	action_row.add_theme_constant_override("separation", 6)
	column.add_child(action_row)
	settle_button = UiTheme.make_button("%s [S]" % LocalizationZhCn.text("action.settle"), 14)
	keep_button = UiTheme.make_button("%s [K]" % LocalizationZhCn.text("action.keep"), 14)
	reset_button = UiTheme.make_button("%s [R]" % LocalizationZhCn.text("action.reset"), 14)
	tool_button = UiTheme.make_button("道具 [Q]", 14)
	pause_button = UiTheme.make_button("菜单 [Esc]", 14)
	settle_button.pressed.connect(func() -> void: settle_requested.emit())
	keep_button.pressed.connect(func() -> void: keep_requested.emit())
	reset_button.pressed.connect(func() -> void: reset_requested.emit())
	tool_button.pressed.connect(func() -> void: tool_requested.emit())
	pause_button.pressed.connect(func() -> void: pause_requested.emit())
	action_row.add_child(settle_button)
	action_row.add_child(keep_button)
	action_row.add_child(reset_button)
	var row2 := HBoxContainer.new()
	row2.add_theme_constant_override("separation", 6)
	column.add_child(row2)
	row2.add_child(tool_button)
	row2.add_child(pause_button)


func refresh(view: Dictionary) -> void:
	target_label.text = "%s  %d" % [LocalizationZhCn.text("hud.target"), int(view.get("target", 0))]
	score_label.text = "%s  %d" % [LocalizationZhCn.text("hud.score"), int(view.get("score", 0))]
	strokes_label.text = "%s  %d" % [LocalizationZhCn.text("hud.strokes"), int(view.get("strokes", 0))]
	var hand: Array = view.get("hand", [])
	hand_label.text = "%s %d/5" % [LocalizationZhCn.text("hud.hand"), hand.size()]

	var combo: Dictionary = view.get("combo", {})
	var participant_indices: Array = combo.get("participant_indices", [])
	for index in 5:
		var box := slot_boxes[index]
		if index < hand.size():
			var slot: Dictionary = hand[index]
			var color: Color = _ball_color(str(slot.get("color_id", "")))
			var style: StyleBoxFlat = UiTheme.panel_style(UiTheme.ACCENT if participant_indices.has(index) else UiTheme.TEXT_DIM, Color("132334"))
			style.bg_color = color.darkened(0.35)
			box.add_theme_stylebox_override("panel", style)
			slot_labels[index].text = str(slot.get("number", ""))
			var physical: bool = bool(slot.get("has_physical_ball", false))
			slot_caption_labels[index].text = "球#%d" % int(slot.get("physical_ball_id", 0)) if physical else "副本"
		else:
			box.add_theme_stylebox_override("panel", UiTheme.panel_style(UiTheme.DISABLED, Color("132334")))
			slot_labels[index].text = ""
			slot_caption_labels[index].text = ""

	combo_label.text = "%s  %s" % [LocalizationZhCn.text("hud.best"), LocalizationZhCn.combo_name(str(combo.get("type", "none")))]
	formula_label.text = "%d × %d = %d" % [int(combo.get("number_sum", 0)), int(combo.get("multiplier", 0)), int(combo.get("score", 0))]

	var actions: Array = view.get("actions", [])
	settle_button.disabled = not actions.has("settle")
	keep_button.disabled = not actions.has("keep")
	reset_button.disabled = not actions.has("reset")

	var badge_names: Array[String] = []
	for badge_id: String in view.get("badges", []):
		var badge: Dictionary = BadgeCatalog.get_badge(badge_id)
		badge_names.append("[color=#%s]%s[/color]" % [BuildIdentity.color(str(badge.get("build", ""))).to_html(false), str(badge.get("name", badge_id))])
	badges_label.text = "徽章 · %s" % ("  ".join(badge_names) if not badge_names.is_empty() else "暂无")

	var tool_names: Array[String] = []
	for tool_id: String in view.get("tools", {}):
		var tool: Dictionary = ToolCatalog.get_tool(tool_id)
		tool_names.append("%s×%d" % [str(tool.get("name", tool_id)), int(view.tools[tool_id])])
	tools_label.text = "道具 · %s" % ("  ".join(tool_names) if not tool_names.is_empty() else "暂无")
	tool_button.disabled = view.get("tools", {}).is_empty()

	phase_label.text = "%s · %s" % [LocalizationZhCn.text("hud.phase"), LocalizationZhCn.phase_name(str(view.get("phase", "")))]
	power_label.text = "%s %d · %s" % [LocalizationZhCn.text("hud.power"), int(view.get("power", 0)), str(view.get("assist", ""))]


func _ball_color(color_id: String) -> Color:
	var map := {"red": Color("e85d5d"), "blue": Color("4c86e8"), "yellow": Color("e6b94f"), "green": Color("51b977")}
	return map.get(color_id, Color("f2eee4"))
