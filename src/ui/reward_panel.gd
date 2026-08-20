class_name RewardPanel
extends PanelContainer

## Reward three-choice card. Presentation only.

signal reward_chosen(index: int)

var _card_buttons: Array[Button] = []


func _init() -> void:
	custom_minimum_size = Vector2(920, 0)
	add_theme_stylebox_override("panel", UiTheme.panel_style())
	_build()


func _build() -> void:
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 14)
	margin.add_child(column)

	column.add_child(UiTheme.make_label("选择一枚桌边徽章", 28, UiTheme.ACCENT))

	var cards := HBoxContainer.new()
	cards.add_theme_constant_override("separation", 16)
	column.add_child(cards)

	for index in 3:
		var card := UiTheme.make_button("", 15)
		card.custom_minimum_size = Vector2(280, 260)
		card.alignment = HORIZONTAL_ALIGNMENT_LEFT
		card.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		card.pressed.connect(_on_card_pressed.bind(index))
		cards.add_child(card)
		_card_buttons.append(card)

	column.add_child(UiTheme.make_label("点击卡片或按 1 / 2 / 3", 14, UiTheme.ACCENT))


func refresh(choices: Array[String]) -> void:
	for index in 3:
		var button := _card_buttons[index]
		if index < choices.size():
			var badge: Dictionary = BadgeCatalog.get_badge(choices[index])
			var build := str(badge.get("build", ""))
			var build_color := BuildIdentity.color(build).to_html(false)
			var role_key := "role.%s" % str(badge.get("role", ""))
			button.text = "%d · %s\n\n[color=#%s]流派：%s[/color]\n定位：%s\n\n%s" % [
				index + 1,
				str(badge.get("name", badge.id)),
				build_color,
				BuildIdentity.label(build),
				LocalizationZhCn.text(role_key, str(badge.get("role", ""))),
				LocalizationZhCn.text("badge.%s.desc" % badge.id),
			]
			button.disabled = false
		else:
			button.text = ""
			button.disabled = true


func _on_card_pressed(index: int) -> void:
	reward_chosen.emit(index)
