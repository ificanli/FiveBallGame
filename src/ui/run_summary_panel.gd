class_name RunSummaryPanel
extends PanelContainer

## Run-end summary and statistics. Presentation only.

signal restart_requested
signal main_menu_requested

var _title: Label
var _body: Label


func _init() -> void:
	custom_minimum_size = Vector2(720, 0)
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

	_title = UiTheme.make_label("", 32, UiTheme.ACCENT_GOOD)
	column.add_child(_title)

	_body = UiTheme.make_label("", 15, UiTheme.TEXT)
	_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(_body)

	column.add_child(UiTheme.make_label("统计已保存到本机，可通过导出 JSON 查看完整记录", 12, UiTheme.TEXT_DIM))

	var buttons := HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 10)
	column.add_child(buttons)
	var restart := UiTheme.make_button("相同种子重新开始 [R]", 15)
	var menu := UiTheme.make_button("返回主菜单", 15)
	restart.pressed.connect(func() -> void: restart_requested.emit())
	menu.pressed.connect(func() -> void: main_menu_requested.emit())
	buttons.add_child(restart)
	buttons.add_child(menu)


func refresh(run: RunSnapshot) -> void:
	var won: bool = run.phase == "won"
	_title.text = "巡回胜利" if won else "巡回结束"
	_title.add_theme_color_override("font_color", UiTheme.ACCENT_GOOD if won else UiTheme.ACCENT_BAD)

	var lines: Array[String] = []
	var total := 0
	for result: Dictionary in run.table_results:
		var table_name := _table_name(str(result.get("table_id", "")))
		var score := int(result.get("score", 0))
		total += score
		lines.append("%s：%d 分（剩余 %d 杆）" % [table_name, score, int(result.get("strokes_left", 0))])
	if run.table_results.is_empty():
		lines.append("尚未完成任何球桌")
	lines.append("")
	lines.append("最终得分：%d" % total)
	lines.append("已装备徽章：%s" % ("、".join(_badge_names(run.badges)) if not run.badges.is_empty() else "无"))
	var stats: Dictionary = run.statistics
	lines.append("结算 %d 次 · 保留 %d 次 · 爆仓 %d 次 · 道具 %d 次 · 徽章触发 %d 次" % [
		int(stats.get("settles", 0)), int(stats.get("keeps", 0)), int(stats.get("busts", 0)),
		int(stats.get("tools_used", 0)), int(stats.get("badge_triggers", 0)),
	])
	_body.text = "\n".join(lines)


func _table_name(table_id: String) -> String:
	var map := {"qualification": "资格桌", "high_stakes": "高额桌", "dealer": "庄家桌"}
	return map.get(table_id, table_id)


func _badge_names(ids: Array[String]) -> Array[String]:
	var names: Array[String] = []
	for id in ids:
		var badge: Dictionary = BadgeCatalog.get_badge(id)
		names.append(str(badge.get("name", id)))
	return names
