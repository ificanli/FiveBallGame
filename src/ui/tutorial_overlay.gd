class_name TutorialOverlay
extends PanelContainer

## Step-by-step Simplified Chinese guide shown during the run.
## Presentation only; observes the view-model and never mutates rules.

signal dismissed

var _step_label: Label
var _hint_label: Label
var _close_button: Button


func _init() -> void:
	custom_minimum_size = Vector2(620, 0)
	add_theme_stylebox_override("panel", UiTheme.panel_style(UiTheme.ACCENT, Color("0d1f2e")))
	_build()


func _build() -> void:
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_bottom", 14)
	add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 8)
	margin.add_child(column)

	var title_row := HBoxContainer.new()
	column.add_child(title_row)
	var title := UiTheme.make_label("新手引导", 22, UiTheme.ACCENT)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_row.add_child(title)
	_close_button = UiTheme.make_button("关闭引导", 14)
	_close_button.pressed.connect(func() -> void: dismissed.emit())
	title_row.add_child(_close_button)

	_step_label = UiTheme.make_label("", 17, UiTheme.TEXT)
	_step_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(_step_label)

	_hint_label = UiTheme.make_label("", 13, UiTheme.TEXT_DIM)
	_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(_hint_label)


func refresh(phase: String, strokes_left: int, hand_size: int, reward_visible: bool) -> void:
	var step := ""
	var hint := ""
	if reward_visible:
		step = "第 1 步：选择一枚开局徽章，它会决定你本局的打法。"
		hint = "纯净组合打顺子/同色，撞库连锁打反弹，功能墙冒险打复制/染色。"
	elif phase == "aiming":
		step = "移动鼠标瞄准，点击或按空格出杆。"
		hint = "按 1～5 切换力度，Tab 切换辅助线，←/→ 微调角度。瞄准时留意预测轨迹。"
	elif phase == "post_shot_decision":
		step = "球停了。选择「结算」落袋得分，或「保留」再打一杆。"
		hint = "保留会承担爆仓风险：第六球会让当前球组作废。S 结算，K 保留。"
	elif phase == "won":
		step = "球桌达标，进入下一张桌！"
		hint = "每张桌目标更高，徽章会逐步成型。"
	elif phase == "lost":
		step = "杆数耗尽，本桌失败。"
		hint = "按 R 用相同种子重试，调整力度与球路。"
	else:
		step = "欢迎来到五球满贯。"
		hint = "把球打进五槽，凑出顺子、同色、对子等组合来得分。"
	_step_label.text = step
	_hint_label.text = hint
