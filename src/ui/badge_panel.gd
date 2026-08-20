class_name BadgePanel
extends PanelContainer

## Badge management: view, reorder, and replace-on-full-slot. Presentation only.

signal reorder_requested(index: int, delta: int)
signal replace_requested(index: int)
signal closed

var _title: Label
var _hint: Label
var _rows: Array[Dictionary] = []


func _init() -> void:
	custom_minimum_size = Vector2(760, 0)
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

	_title = UiTheme.make_label("徽章管理", 24, UiTheme.ACCENT)
	column.add_child(_title)

	var list := VBoxContainer.new()
	list.add_theme_constant_override("separation", 6)
	column.add_child(list)
	_rows.clear()
	for index in BadgeCatalog.MAX_EQUIPPED:
		var row := _make_badge_row(index)
		list.add_child(row)
		_rows.append({"index": index, "row": row})

	_hint = UiTheme.make_label("", 13, UiTheme.TEXT_DIM)
	column.add_child(_hint)

	var close := UiTheme.make_button("关闭 [Esc]", 15)
	close.pressed.connect(func() -> void: closed.emit())
	column.add_child(close)


func _make_badge_row(index: int) -> PanelContainer:
	var row := PanelContainer.new()
	row.add_theme_stylebox_override("panel", UiTheme.panel_style(UiTheme.TEXT_DIM, Color("132334")))
	var inner := HBoxContainer.new()
	inner.add_theme_constant_override("separation", 10)
	row.add_child(inner)

	var text_col := VBoxContainer.new()
	text_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inner.add_child(text_col)
	var name_label := UiTheme.make_label("", 16, UiTheme.TEXT)
	text_col.add_child(name_label)
	var desc_label := UiTheme.make_label("", 12, UiTheme.TEXT_DIM)
	desc_label.custom_minimum_size = Vector2(0, 32)
	text_col.add_child(desc_label)

	var up := UiTheme.make_button("↑", 14)
	var down := UiTheme.make_button("↓", 14)
	var replace := UiTheme.make_button("替换", 14)
	up.pressed.connect(func() -> void: reorder_requested.emit(index, -1))
	down.pressed.connect(func() -> void: reorder_requested.emit(index, 1))
	replace.pressed.connect(func() -> void: replace_requested.emit(index))
	inner.add_child(up)
	inner.add_child(down)
	inner.add_child(replace)

	return row


func refresh(equipped: Array[String], mode: String = "manage", candidate_id: String = "") -> void:
	_title.text = "选择被替换的徽章" if mode == "replace" else "徽章管理"
	var candidate_name := str(BadgeCatalog.get_badge(candidate_id).get("name", candidate_id)) if candidate_id != "" else ""
	_hint.text = "点击 ↑ / ↓ 调整顺序（影响结算顺序）" if mode == "manage" else "选择将被「%s」替换的徽章" % candidate_name
	for entry: Dictionary in _rows:
		var index := int(entry.index)
		var row: PanelContainer = entry.row
		var inner: HBoxContainer = row.get_child(0)
		var text_col: VBoxContainer = inner.get_child(0)
		var name_label: Label = text_col.get_child(0)
		var desc_label: Label = text_col.get_child(1)
		var up_button: Button = inner.get_child(1)
		var down_button: Button = inner.get_child(2)
		var replace_button: Button = inner.get_child(3)
		if index < equipped.size():
			var badge_id := str(equipped[index])
			var badge: Dictionary = BadgeCatalog.get_badge(badge_id)
			var build := str(badge.get("build", ""))
			name_label.text = "%d · %s" % [index + 1, str(badge.get("name", badge_id))]
			name_label.add_theme_color_override("font_color", BuildIdentity.color(build))
			desc_label.text = "%s · %s" % [BuildIdentity.label(build), LocalizationZhCn.text("badge.%s.desc" % badge_id)]
			row.visible = true
			up_button.visible = mode == "manage"
			down_button.visible = mode == "manage"
			replace_button.visible = mode == "replace"
		else:
			row.visible = mode == "manage"
			name_label.text = "%d · 空槽" % [index + 1]
			name_label.add_theme_color_override("font_color", UiTheme.TEXT_DIM)
			desc_label.text = "尚未装备徽章"
			up_button.visible = false
			down_button.visible = false
			replace_button.visible = false
