class_name TechnicalTable
extends Control

const TABLE_RECT := Rect2(55.0, 75.0, 1000.0, 620.0)
const DRAG_MAX_DISTANCE := 260.0
const DRAG_DEAD_ZONE_RATIO := 0.10
const COLOR_MAP := {
	"red": Color("e85d5d"), "blue": Color("4c86e8"),
	"yellow": Color("e6b94f"), "green": Color("51b977"), "": Color("f2eee4")
}
const MODES := ["concise", "standard", "full"]
const MODE_KEYS := ["assist.concise", "assist.standard", "assist.full"]

var seed := 20260819
var run_controller: RunController
var controller: CoreLoopController
var preview_service := TrajectoryPreview.new()
var aim_direction := Vector2.RIGHT
var power_level := 3
var assistance_index := 1
var preview: Dictionary = {}
var preview_request_id := 0
var playing := false
var playback_result: SimulationResult
var playback_elapsed := 0.0
var display_positions: Dictionary = {}
var feedback_text := LocalizationZhCn.text("feedback.ready")
var feedback_color := Color("8fd7cf")

# 输入模式: "drag" = 拉杆出手, "fine" = 精细瞄准 (仅影响输入流程, 不进入规则/回放)
var input_mode := "drag"
var drag_active := false
var drag_current_pos := Vector2.ZERO

# M3.5 UI panels
var hud: HudPanel
var reward_panel: RewardPanel
var tool_selector: ToolSelector
var badge_panel: BadgePanel
var run_summary: RunSummaryPanel
var pause_menu: PauseMenu
var tutorial: TutorialOverlay
var _modal_overlay: ColorRect
var _modal_center: CenterContainer
var _active_modal: Control = null
var _pending_reward_badge := ""
var _pending_tool_id := ""
var _pending_tool_ball_id := -1

var snapshot: TableSnapshot:
	get: return controller.state.table if controller != null else null


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_ALL
	grab_focus()
	_build_ui()
	input_mode = GameSession.input_mode
	start_run_same_seed()
	print("M3_RUN_READY seed=%d rules=%s" % [seed, RunSnapshot.RULES_VERSION])


func _build_ui() -> void:
	hud = HudPanel.new()
	hud.position = Vector2(1055, 70)
	hud.visible = false
	add_child(hud)
	hud.settle_requested.connect(settle)
	hud.keep_requested.connect(keep)
	hud.reset_requested.connect(reset_same_seed)
	hud.tool_requested.connect(_open_tool_selector)
	hud.pause_requested.connect(_open_pause)
	hud.badge_requested.connect(func() -> void: _open_badge_panel("manage"))
	hud.mode_toggled.connect(_toggle_input_mode)
	hud.shoot_requested.connect(shoot)
	hud.nudge_requested.connect(_nudge)

	_modal_overlay = UiTheme.make_modal_overlay()
	_modal_overlay.visible = false
	add_child(_modal_overlay)
	_modal_center = CenterContainer.new()
	_modal_center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_modal_overlay.add_child(_modal_center)

	reward_panel = RewardPanel.new()
	reward_panel.reward_chosen.connect(_on_reward_chosen)
	tool_selector = ToolSelector.new()
	tool_selector.tool_selected.connect(_on_tool_selected)
	tool_selector.tool_cancelled.connect(_close_modal)
	badge_panel = BadgePanel.new()
	badge_panel.reorder_requested.connect(_on_badge_reorder)
	badge_panel.replace_requested.connect(_on_badge_replace)
	badge_panel.closed.connect(_close_modal)
	run_summary = RunSummaryPanel.new()
	run_summary.restart_requested.connect(reset_same_seed)
	run_summary.main_menu_requested.connect(_back_to_menu)
	pause_menu = PauseMenu.new()
	pause_menu.resume_requested.connect(_close_modal)
	pause_menu.restart_requested.connect(reset_same_seed)
	pause_menu.main_menu_requested.connect(_back_to_menu)
	pause_menu.badge_requested.connect(func() -> void: _open_badge_panel("manage"))

	for panel: Control in [reward_panel, tool_selector, badge_panel, run_summary, pause_menu]:
		panel.visible = false
		_modal_center.add_child(panel)

	tutorial = TutorialOverlay.new()
	tutorial.dismissed.connect(func() -> void: tutorial.visible = false)
	tutorial.visible = false
	add_child(tutorial)
	tutorial.position = Vector2((size.x - 620) / 2.0, size.y - 190)


func _process(delta: float) -> void:
	if playing:
		playback_elapsed += delta
		var tick := mini(playback_result.ticks, int(playback_elapsed / PhysicsConfig.default_config().fixed_delta))
		_apply_playback_tick(tick)
		if tick >= playback_result.ticks:
			playing = false
			_apply_snapshot_positions()
			_set_feedback_from_state()
			_refresh_preview()
			_sync_ui()
		queue_redraw()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_ESCAPE:
				if drag_active:
					_cancel_drag()
				elif _active_modal != null:
					_close_modal()
				elif _pending_tool_id != "":
					_cancel_tool_target()
				elif hud.visible:
					_open_pause()
			KEY_1, KEY_2, KEY_3:
				if run_controller != null and run_controller.state.phase == "reward" and _active_modal == null:
					_on_reward_chosen(int(event.keycode - KEY_1))
				elif _can_aim() and _active_modal == null:
					power_level = int(event.keycode - KEY_0)
					_refresh_preview()
					_sync_ui()
			KEY_4, KEY_5:
				if _can_aim() and _active_modal == null:
					power_level = int(event.keycode - KEY_0)
					_refresh_preview()
					_sync_ui()
			KEY_SPACE, KEY_ENTER:
				if _active_modal == null and not drag_active:
					shoot()
			KEY_S:
				if _active_modal == null:
					settle()
			KEY_K:
				if _active_modal == null:
					keep()
			KEY_R:
				if _active_modal == null:
					reset_same_seed()
			KEY_Q:
				if _active_modal == null and _pending_tool_id == "":
					_open_tool_selector()
			KEY_B:
				if _active_modal == null and hud.visible:
					_open_badge_panel("manage")
			KEY_TAB:
				if _can_aim() and _active_modal == null:
					assistance_index = (assistance_index + 1) % MODES.size()
					_refresh_preview()
					_sync_ui()
			KEY_LEFT:
				if _can_aim() and _active_modal == null and not drag_active:
					_nudge(-1)
			KEY_RIGHT:
				if _can_aim() and _active_modal == null and not drag_active:
					_nudge(1)
	elif event is InputEventMouseMotion and _active_modal == null:
		if drag_active and _can_aim():
			drag_current_pos = (event as InputEventMouseMotion).position
			_update_drag(drag_current_pos)
		elif input_mode == "fine" and _can_aim():
			_aim_at((event as InputEventMouseMotion).position)
	elif event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		if mouse.button_index == MOUSE_BUTTON_LEFT and mouse.pressed:
			if _pending_tool_id != "":
				_handle_tool_target_click(mouse.position)
				return
			if not _can_aim() or _active_modal != null:
				return
			if input_mode == "drag":
				if TABLE_RECT.has_point(mouse.position):
					drag_active = true
					drag_current_pos = mouse.position
					_update_drag(drag_current_pos)
			else:
				_aim_at(mouse.position)
		elif mouse.button_index == MOUSE_BUTTON_LEFT and not mouse.pressed and drag_active:
			_finish_drag()
		elif mouse.button_index == MOUSE_BUTTON_RIGHT and mouse.pressed and drag_active:
			_cancel_drag()


func start_run_same_seed() -> void:
	playing = false
	run_controller = RunController.new(RunSnapshot.create(seed))
	controller = null
	playback_result = null
	playback_elapsed = 0.0
	feedback_text = "请选择第一枚桌边徽章"
	feedback_color = Color("8fd7cf")
	display_positions.clear()
	preview = {}
	_pending_tool_id = ""
	_pending_tool_ball_id = -1
	_close_modal()
	_sync_ui()
	queue_redraw()


func reset_same_seed() -> void:
	start_run_same_seed()


func choose_reward(index: int) -> void:
	_on_reward_chosen(index)


func _on_reward_chosen(index: int) -> void:
	if run_controller == null or run_controller.state.phase != "reward" or index < 0 or index >= run_controller.state.reward_choices.size():
		return
	var badge_id: String = run_controller.state.reward_choices[index]
	if run_controller.state.badges.size() >= BadgeCatalog.MAX_EQUIPPED:
		_pending_reward_badge = badge_id
		_open_badge_panel("replace", badge_id)
		return
	_apply_reward(badge_id)


func _apply_reward(badge_id: String) -> void:
	var result := run_controller.choose_reward(badge_id)
	if result.ok:
		controller = run_controller.table_controller
		feedback_text = "已装备「%s」，进入%s" % [BadgeCatalog.get_badge(badge_id).name, RunContent.table_config(run_controller.state.table_index).name]
		_close_modal()
		_apply_snapshot_positions()
		_refresh_preview()
		_sync_ui()
		queue_redraw()


func _on_badge_replace(index: int) -> void:
	if run_controller == null or _pending_reward_badge == "":
		return
	var result := run_controller.choose_reward(_pending_reward_badge, index)
	if result.ok:
		controller = run_controller.table_controller
		feedback_text = "已替换为「%s」" % BadgeCatalog.get_badge(_pending_reward_badge).name
		_pending_reward_badge = ""
		_close_modal()
		_apply_snapshot_positions()
		_refresh_preview()
		_sync_ui()
		queue_redraw()


func _on_badge_reorder(index: int, delta: int) -> void:
	if run_controller == null:
		return
	var target := index + delta
	run_controller.reorder_badges(index, target)
	_sync_ui()


func shoot() -> void:
	if not _can_aim() or _active_modal != null:
		return
	var result := controller.shoot(ShotInput.create(1, aim_direction, power_level), true)
	if not result.ok:
		feedback_text = LocalizationZhCn.format("feedback.rejected", [result.code])
		feedback_color = Color("ff7a7a")
		return
	playback_result = result.simulation
	playing = true
	playback_elapsed = 0.0
	feedback_text = LocalizationZhCn.text("feedback.shot")
	feedback_color = Color("f5cf72")
	_sync_ui()


func settle() -> void:
	if run_controller == null or controller == null or _active_modal != null:
		return
	var result := run_controller.settle(_settlement_evidence())
	if result.ok:
		feedback_text = LocalizationZhCn.format("feedback.settled", [result.banked_score])
		feedback_color = Color("f5cf72")
		if run_controller.state.phase == "reward":
			controller = null
			feedback_text = "球桌达标！请选择下一枚徽章"
		elif run_controller.state.phase == "won":
			controller = null
			feedback_text = "巡回完成！三张球桌全部达标"
		else:
			controller = run_controller.table_controller
			_set_feedback_from_state()
		_refresh_preview()
		_sync_ui()
		queue_redraw()


func keep() -> void:
	if run_controller == null or controller == null or _active_modal != null:
		return
	var result := run_controller.keep()
	if result.ok:
		feedback_text = LocalizationZhCn.text("feedback.kept")
		feedback_color = Color("8fd7cf")
		_refresh_preview()
		_sync_ui()
		queue_redraw()


func use_first_available_tool() -> void:
	_open_tool_selector()


func legal_actions() -> Array[String]:
	return controller.allowed_actions() if controller != null else []


func view_model() -> Dictionary:
	var tools: Dictionary = run_controller.state.tools if run_controller != null else {}
	var badges: Array[String] = run_controller.state.badges if run_controller != null else []
	var assist_name := ""
	if assistance_index >= 0 and assistance_index < MODE_KEYS.size():
		assist_name = LocalizationZhCn.text(MODE_KEYS[assistance_index])
	if controller == null:
		return {"run_phase": run_controller.state.phase if run_controller != null else "none", "tools": tools, "badges": badges, "power": power_level, "assist": assist_name}
	var state := controller.state
	return {
		"score": state.score, "target": state.target_score,
		"strokes": state.strokes_remaining, "phase": state.phase,
		"hand": state.hand.map(func(slot: HandSlot) -> Dictionary: return slot.to_dict()),
		"combo": state.combo.duplicate(true), "actions": legal_actions(),
		"tools": tools, "badges": badges, "power": power_level, "assist": assist_name,
	}


func _sync_ui() -> void:
	var phase := run_controller.state.phase if run_controller != null else "none"
	var playing_phase: bool = run_controller != null and run_controller.state.phase == "playing"
	hud.visible = playing_phase
	if hud.visible:
		hud.refresh(view_model())

	# Phase-driven modals
	if _active_modal == null:
		if run_controller != null and run_controller.state.phase == "reward":
			reward_panel.refresh(run_controller.state.reward_choices)
			_show_modal(reward_panel)
		elif run_controller != null and run_controller.state.phase in ["won", "lost"]:
			run_summary.refresh(run_controller.state)
			_show_modal(run_summary)

	# Tutorial
	if GameSession.tutorial_mode and playing_phase and _active_modal == null:
		var state := controller.state
		tutorial.refresh(state.phase, state.strokes_remaining, state.hand.size(), false)
		tutorial.visible = true
	else:
		tutorial.visible = false


func _open_tool_selector() -> void:
	if run_controller == null or controller == null:
		return
	var legal: Array[String] = []
	for tool_id: String in run_controller.state.tools:
		var tool := ToolCatalog.get_tool(tool_id)
		var phase_ok: bool = (str(tool.get("phase", "")) == "aiming" and controller.state.phase == "aiming") or (str(tool.get("phase", "")) == "post_shot_decision" and controller.state.phase == "post_shot_decision") or (str(tool.get("phase", "")) == "stopped" and controller.state.phase in ["post_shot_decision"])
		if phase_ok:
			legal.append(tool_id)
	tool_selector.refresh(run_controller.state.tools, legal)
	_show_modal(tool_selector)


func _on_tool_selected(tool_id: String) -> void:
	var tool := ToolCatalog.get_tool(tool_id)
	if tool.is_empty():
		return
	var target: String = str(tool.get("target", "none"))
	if target == "none":
		_close_modal()
		_apply_tool(tool_id, {})
	else:
		_pending_tool_id = tool_id
		_pending_tool_ball_id = -1
		_close_modal()
		feedback_text = "请点击桌面上的一颗本手球（Esc 取消）"
		feedback_color = Color("f5cf72")
		queue_redraw()


func _apply_tool(tool_id: String, parameters: Dictionary) -> void:
	var result := run_controller.use_tool(tool_id, parameters)
	if result.ok:
		controller = run_controller.table_controller
		feedback_text = "道具已使用"
		feedback_color = Color("8fd7cf")
		_apply_snapshot_positions()
		_refresh_preview()
		_sync_ui()
		queue_redraw()
	else:
		feedback_text = LocalizationZhCn.format("feedback.rejected", [result.code])
		feedback_color = Color("ff7a7a")
		queue_redraw()


func _cancel_tool_target() -> void:
	_pending_tool_id = ""
	_pending_tool_ball_id = -1
	feedback_text = LocalizationZhCn.text("feedback.ready")
	feedback_color = Color("8fd7cf")
	queue_redraw()


func _aim_at(screen_pos: Vector2) -> void:
	if snapshot == null or not _can_aim():
		return
	var cue := snapshot.find_ball(1)
	if cue == null:
		return
	var direction: Vector2 = screen_pos - TABLE_RECT.position - cue.position
	if direction.length_squared() > 4.0:
		aim_direction = direction.normalized()
		_refresh_preview()


func _nudge(step: int) -> void:
	aim_direction = aim_direction.rotated(deg_to_rad(0.5 * step))
	_refresh_preview()


func _toggle_input_mode() -> void:
	_cancel_drag()
	var next: String = "fine" if GameSession.input_mode == "drag" else "drag"
	GameSession.set_input_mode(next)
	input_mode = next
	feedback_text = LocalizationZhCn.text("feedback.drag_ready" if next == "drag" else "feedback.fine_ready")
	feedback_color = Color("8fd7cf")
	_sync_ui()
	queue_redraw()


func _update_drag(mouse_pos: Vector2) -> void:
	if snapshot == null or not _can_aim():
		return
	var cue := snapshot.find_ball(1)
	if cue == null:
		return
	var drag_vec: Vector2 = cue.position - (mouse_pos - TABLE_RECT.position)
	if drag_vec.length_squared() > 1.0:
		aim_direction = drag_vec.normalized()
	var ratio := clampf(drag_vec.length() / DRAG_MAX_DISTANCE, 0.0, 1.0)
	power_level = clampi(int(ratio * 5.0) + 1, 1, 5)
	_refresh_preview()
	_sync_ui()
	queue_redraw()


func _finish_drag() -> void:
	drag_active = false
	queue_redraw()
	if snapshot == null or not _can_aim():
		return
	var cue := snapshot.find_ball(1)
	if cue == null:
		return
	var drag_len: float = (drag_current_pos - TABLE_RECT.position).distance_to(cue.position)
	if drag_len < DRAG_MAX_DISTANCE * DRAG_DEAD_ZONE_RATIO:
		feedback_text = LocalizationZhCn.text("feedback.drag_cancelled")
		feedback_color = Color("9db1c4")
		queue_redraw()
		return
	shoot()


func _cancel_drag() -> void:
	drag_active = false
	queue_redraw()


func _handle_tool_target_click(position: Vector2) -> void:
	if snapshot == null:
		return
	var table_pos: Vector2 = position - TABLE_RECT.position
	for ball: BallState in snapshot.balls:
		if ball.kind != "number":
			continue
		if table_pos.distance_to(ball.position) > ball.radius + 14.0:
			continue
		var slot: HandSlot = controller.state.find_physical_slot(ball.id)
		if slot == null:
			continue
		_pending_tool_ball_id = ball.id
		_finish_tool_target()
		return


func _finish_tool_target() -> void:
	var tool_id := _pending_tool_id
	var ball_id := _pending_tool_ball_id
	if tool_id == "color_chalk":
		_show_color_picker(ball_id)
	elif tool_id == "number_sticker":
		_show_delta_picker(ball_id)
	else:
		_pending_tool_id = ""
		_pending_tool_ball_id = -1
		_apply_tool(tool_id, {"ball_id": ball_id})


func _show_color_picker(ball_id: int) -> void:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", UiTheme.panel_style())
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_bottom", 14)
	panel.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	margin.add_child(column)
	column.add_child(UiTheme.make_label("选择目标颜色", 18, UiTheme.ACCENT))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	column.add_child(row)
	for color_id in ["red", "blue", "yellow", "green"]:
		var button := UiTheme.make_button(_color_name(color_id), 15)
		button.add_theme_color_override("font_color", COLOR_MAP[color_id])
		button.pressed.connect(_on_color_chosen.bind(ball_id, color_id))
		row.add_child(button)
	_show_modal(panel)


func _show_delta_picker(ball_id: int) -> void:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", UiTheme.panel_style())
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_bottom", 14)
	panel.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	margin.add_child(column)
	column.add_child(UiTheme.make_label("调整数字", 18, UiTheme.ACCENT))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	column.add_child(row)
	for delta in [-1, 1]:
		var button := UiTheme.make_button("+1" if delta == 1 else "-1", 16)
		button.pressed.connect(_on_delta_chosen.bind(ball_id, delta))
		row.add_child(button)
	_show_modal(panel)


func _on_color_chosen(ball_id: int, color_id: String) -> void:
	_pending_tool_id = ""
	_pending_tool_ball_id = -1
	_close_modal()
	_apply_tool("color_chalk", {"ball_id": ball_id, "color_id": color_id})


func _on_delta_chosen(ball_id: int, delta: int) -> void:
	_pending_tool_id = ""
	_pending_tool_ball_id = -1
	_close_modal()
	_apply_tool("number_sticker", {"ball_id": ball_id, "delta": delta})


func _open_badge_panel(mode: String, candidate_id: String = "") -> void:
	if run_controller == null:
		return
	badge_panel.refresh(run_controller.state.badges, mode, candidate_id)
	_show_modal(badge_panel)


func _open_pause() -> void:
	_show_modal(pause_menu)


func _show_modal(panel: Control) -> void:
	_active_modal = panel
	if panel.get_parent() != _modal_center:
		_modal_center.add_child(panel)
	for p: Control in [reward_panel, tool_selector, badge_panel, run_summary, pause_menu]:
		p.visible = p == panel
	_modal_overlay.visible = true
	_sync_ui()


func _close_modal() -> void:
	_active_modal = null
	for p: Control in [reward_panel, tool_selector, badge_panel, run_summary, pause_menu]:
		p.visible = false
	for child: Node in _modal_center.get_children():
		if child not in [reward_panel, tool_selector, badge_panel, run_summary, pause_menu]:
			child.queue_free()
	_modal_overlay.visible = false
	_sync_ui()


func _back_to_menu() -> void:
	GameSession.tutorial_mode = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _can_aim() -> bool:
	return not playing and controller != null and controller.state.phase == "aiming"


func _settlement_evidence() -> Dictionary:
	var events: Array = controller.state.last_rule_events
	var rail_hits := 0
	var copies := 0
	var dyes := 0
	var wall_kinds: Array[String] = []
	if controller.last_simulation != null:
		for event: PhysicsEvent in controller.last_simulation.events:
			if event.type == "rail_collision": rail_hits += 1
			elif event.type == "copy":
				copies += 1
				if not wall_kinds.has("copy"): wall_kinds.append("copy")
			elif event.type == "dye":
				dyes += 1
				if not wall_kinds.has("dye"): wall_kinds.append("dye")
	return {"power_level": power_level, "rail_hits": rail_hits, "copy_count": copies, "dye_count": dyes, "dyed_participant_count": dyes, "wall_kinds": wall_kinds, "indirect_participant_count": maxi(0, controller.state.hand.size() - 1), "maximum_activation_depth": maxi(1, controller.state.hand.size())}


func _refresh_preview() -> void:
	if not _can_aim() or snapshot == null:
		preview = {}
		return
	preview_request_id += 1
	preview = preview_service.request(snapshot, ShotInput.create(1, aim_direction, power_level), MODES[assistance_index], preview_request_id)
	queue_redraw()


func _apply_snapshot_positions() -> void:
	display_positions.clear()
	if snapshot == null:
		return
	for ball: BallState in snapshot.balls:
		display_positions[ball.id] = ball.position


func _apply_playback_tick(tick: int) -> void:
	for id_text: Variant in playback_result.trajectories:
		var samples: Array = playback_result.trajectories[id_text]
		if not samples.is_empty():
			var position_data: Dictionary = samples[mini(tick, samples.size() - 1)].position
			display_positions[int(id_text)] = Vector2(position_data.x, position_data.y)


func _set_feedback_from_state() -> void:
	var state := controller.state
	if state.phase == "won":
		feedback_text = LocalizationZhCn.text("feedback.win")
		feedback_color = Color("6ff0aa")
	elif state.phase == "lost":
		feedback_text = LocalizationZhCn.text("feedback.loss")
		feedback_color = Color("ff7a7a")
	elif state.shot_busted:
		feedback_text = LocalizationZhCn.text("feedback.bust")
		feedback_color = Color("ff6b6b")
	elif state.phase == "post_shot_decision":
		feedback_text = LocalizationZhCn.format("feedback.decide", [state.combo.score])
		feedback_color = Color("f5cf72")
	else:
		feedback_text = LocalizationZhCn.text("feedback.empty")


func _color_name(color_id: String) -> String:
	return {"red": "红", "blue": "蓝", "yellow": "黄", "green": "绿"}.get(color_id, color_id)


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("07111d"))
	draw_string(ThemeDB.fallback_font, Vector2(55, 38), "%s · %s" % [LocalizationZhCn.text("game.title"), LocalizationZhCn.text("screen.tutorial")], HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("dceaf7"))
	draw_rect(TABLE_RECT.grow(12), Color("172638"), true)
	draw_rect(TABLE_RECT, Color("0b493f"), true)
	draw_rect(TABLE_RECT, Color("85a496"), false, 3.0)
	if controller != null:
		_draw_preview()
		_draw_walls()
		_draw_balls()
		_draw_drag_assist()
	_draw_power_gauge()
	draw_string(ThemeDB.fallback_font, Vector2(55, 735), feedback_text, HORIZONTAL_ALIGNMENT_LEFT, 700, 18, feedback_color)


func _draw_preview() -> void:
	if not _can_aim() or not preview.get("ok", false):
		return
	for id_text: Variant in preview.get("trajectories", {}):
		var samples: Array = preview.trajectories[id_text]
		if samples.size() < 2:
			continue
		var points := PackedVector2Array()
		for sample: Dictionary in samples:
			points.append(TABLE_RECT.position + Vector2(sample.position.x, sample.position.y))
		draw_polyline(points, Color(1, 1, 1, 0.6) if int(id_text) == 1 else Color(0.4, 0.95, 0.88, 0.35), 2.0)


func _draw_walls() -> void:
	for wall: WallState in snapshot.walls:
		var rect := Rect2(TABLE_RECT.position + wall.rect.position, wall.rect.size)
		var color: Color = Color("49d4ca") if wall.kind == "copy" else COLOR_MAP.get(wall.color_id, Color.WHITE)
		draw_rect(rect, color, true)
		draw_string(ThemeDB.fallback_font, rect.position + Vector2(-8, -8), "%s %s" % [LocalizationZhCn.text("hud.wall.copy"), "●" if wall.charge > 0 else "○"] if wall.kind == "copy" else "%s·红" % LocalizationZhCn.text("hud.wall.dye"), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, color)


func _draw_balls() -> void:
	for ball: BallState in snapshot.balls:
		var center: Vector2 = TABLE_RECT.position + display_positions.get(ball.id, ball.position)
		var state := controller.state.collection_state(ball.id) if ball.kind == "number" else "cue"
		var color: Color = COLOR_MAP.get(ball.color_id, Color.WHITE)
		if state == "waste": color = color.darkened(0.62)
		draw_circle(center, ball.radius, color)
		draw_circle(center, ball.radius + (4.0 if state == "hand" else 0.0), Color("f4c95d") if state == "hand" else Color("1b2734"), false, 3.0)
		draw_string(ThemeDB.fallback_font, center + Vector2(-7, 6), "C" if ball.kind == "cue" else str(ball.number), HORIZONTAL_ALIGNMENT_CENTER, 14, 16, Color("102030"))


func _draw_drag_assist() -> void:
	if not drag_active or snapshot == null:
		return
	var cue := snapshot.find_ball(1)
	if cue == null:
		return
	var cue_center: Vector2 = TABLE_RECT.position + cue.position
	draw_line(drag_current_pos, cue_center, Color(1, 1, 1, 0.32), 2.0, true)
	var first_event: Dictionary = preview.get("first_event", {}) if preview.get("ok", false) else {}
	if not first_event.is_empty():
		var contact: Dictionary = first_event.get("point", {})
		if not contact.is_empty():
			draw_circle(TABLE_RECT.position + Vector2(contact.x, contact.y), cue.radius, Color(1, 1, 1, 0.26))
	draw_string(ThemeDB.fallback_font, cue_center + Vector2(-12, -32), str(power_level), HORIZONTAL_ALIGNMENT_CENTER, 22, 26, Color("f5cf72"))


func _draw_power_gauge() -> void:
	if not _can_aim():
		return
	var origin: Vector2 = Vector2(75, 700)
	var cell := Vector2(34.0, 16.0)
	for level in 5:
		var rect := Rect2(origin + Vector2(level * (cell.x + 6), 0), cell)
		var active: bool = level + 1 == power_level
		draw_rect(rect, Color("f5cf72") if active else Color("2a3b4d"), true)
		draw_rect(rect, Color("8a9ab0"), false, 1.0)
		draw_string(ThemeDB.fallback_font, rect.position + Vector2(11, 12), str(level + 1), HORIZONTAL_ALIGNMENT_CENTER, 18, 14, Color("102030"))
	draw_string(ThemeDB.fallback_font, origin + Vector2(0, -4), LocalizationZhCn.text("hud.power"), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("9db1c4"))
