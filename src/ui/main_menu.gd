class_name MainMenu
extends Control


func _ready() -> void:
	var bg := ColorRect.new()
	bg.color = UiTheme.BG
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 18)
	column.custom_minimum_size = Vector2(360, 0)
	center.add_child(column)

	var title := UiTheme.make_label(LocalizationZhCn.text("game.title"), 44, UiTheme.ACCENT)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(title)

	var subtitle := UiTheme.make_label("三套打法 · 三张球桌 · 15～25 分钟短巡回", 16, UiTheme.TEXT_DIM)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(subtitle)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 10)
	column.add_child(spacer)

	var start := UiTheme.make_button("开始巡回", 20)
	start.custom_minimum_size = Vector2(0, 56)
	start.pressed.connect(_start_run)
	column.add_child(start)

	var tutorial := UiTheme.make_button("教程", 18)
	tutorial.pressed.connect(_start_tutorial)
	column.add_child(tutorial)

	var quit := UiTheme.make_button("退出", 16)
	quit.pressed.connect(func() -> void: get_tree().quit())
	column.add_child(quit)

	var version := UiTheme.make_label("M3.5 · 中文版", 12, UiTheme.TEXT_DIM)
	version.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(version)


func _start_run() -> void:
	get_tree().change_scene_to_file("res://scenes/technical_table.tscn")


func _start_tutorial() -> void:
	GameSession.tutorial_mode = true
	get_tree().change_scene_to_file("res://scenes/technical_table.tscn")
