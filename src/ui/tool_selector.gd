class_name ToolSelector
extends PanelContainer

## Tool picker with descriptions. Presentation only.

signal tool_selected(tool_id: String)
signal tool_cancelled

var _rows: Array[Dictionary] = []


func _init() -> void:
	custom_minimum_size = Vector2(620, 0)
	add_theme_stylebox_override("panel", UiTheme.panel_style())
	_build()


func _build() -> void:
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_bottom", 14)
	add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	margin.add_child(column)

	column.add_child(UiTheme.make_label("选择道具", 24, UiTheme.ACCENT))

	var list := VBoxContainer.new()
	list.add_theme_constant_override("separation", 8)
	column.add_child(list)
	_rows.clear()

	for tool: Dictionary in ToolCatalog.TOOLS:
		var row := _make_tool_row(str(tool.id))
		list.add_child(row)
		_rows.append({"id": str(tool.id), "row": row})

	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation", 10)
	column.add_child(footer)
	var cancel := UiTheme.make_button("取消 [Esc]", 15)
	cancel.pressed.connect(func() -> void: tool_cancelled.emit())
	footer.add_child(cancel)
	footer.add_child(UiTheme.make_label("点击使用后，如需目标请点选桌面上的一颗球", 13, UiTheme.TEXT_DIM))


func _make_tool_row(tool_id: String) -> PanelContainer:
	var row := PanelContainer.new()
	row.add_theme_stylebox_override("panel", UiTheme.panel_style(UiTheme.TEXT_DIM, Color("132334")))
	var inner := HBoxContainer.new()
	inner.add_theme_constant_override("separation", 10)
	row.add_child(inner)

	var text_col := VBoxContainer.new()
	text_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inner.add_child(text_col)
	var tool: Dictionary = ToolCatalog.get_tool(tool_id)
	text_col.add_child(UiTheme.make_label(str(tool.get("name", tool_id)), 17, UiTheme.ACCENT_GOOD))
	var desc := UiTheme.make_label(LocalizationZhCn.text("tool.%s.desc" % tool_id), 13, UiTheme.TEXT)
	desc.custom_minimum_size = Vector2(0, 40)
	text_col.add_child(desc)

	var use := UiTheme.make_button("使用", 14)
	use.pressed.connect(func() -> void: tool_selected.emit(tool_id))
	inner.add_child(use)
	return row


func refresh(inventory: Dictionary, legal_tool_ids: Array[String]) -> void:
	for entry: Dictionary in _rows:
		var tool_id := str(entry.id)
		var row: PanelContainer = entry.row
		var count := int(inventory.get(tool_id, 0))
		var legal: bool = legal_tool_ids.has(tool_id)
		row.visible = count > 0
		var use_button: Button = _find_use_button(row)
		if use_button != null:
			use_button.disabled = not legal
			use_button.text = "使用×%d" % count if legal else "不可用"


func _find_use_button(row: PanelContainer) -> Button:
	var inner: HBoxContainer = row.get_child(0)
	for child in inner.get_children():
		if child is Button:
			return child
	return null
