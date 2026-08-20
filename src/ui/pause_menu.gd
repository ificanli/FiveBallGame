class_name PauseMenu
extends PanelContainer

## Pause menu. Presentation only.

signal resume_requested
signal restart_requested
signal main_menu_requested
signal badge_requested


func _init() -> void:
	custom_minimum_size = Vector2(320, 0)
	add_theme_stylebox_override("panel", UiTheme.panel_style())
	_build()


func _build() -> void:
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 12)
	margin.add_child(column)

	column.add_child(UiTheme.make_label("暂停", 28, UiTheme.ACCENT))

	var resume := UiTheme.make_button("继续 [Esc]", 16)
	var badge := UiTheme.make_button("徽章管理 [B]", 16)
	var restart := UiTheme.make_button("重开本局 [R]", 16)
	var menu := UiTheme.make_button("返回主菜单", 16)
	resume.pressed.connect(func() -> void: resume_requested.emit())
	badge.pressed.connect(func() -> void: badge_requested.emit())
	restart.pressed.connect(func() -> void: restart_requested.emit())
	menu.pressed.connect(func() -> void: main_menu_requested.emit())
	column.add_child(resume)
	column.add_child(badge)
	column.add_child(restart)
	column.add_child(menu)
