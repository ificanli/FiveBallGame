class_name TechnicalTable
extends Control

const TABLE_RECT := Rect2(55.0, 75.0, 1000.0, 620.0)
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

var snapshot: TableSnapshot:
	get: return controller.state.table if controller != null else null


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_ALL
	grab_focus()
	start_run_same_seed()
	print("M3_RUN_READY seed=%d rules=%s" % [seed, RunSnapshot.RULES_VERSION])


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
		queue_redraw()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and _can_aim():
		var cue := snapshot.find_ball(1)
		var direction: Vector2 = (event as InputEventMouseMotion).position - TABLE_RECT.position - cue.position
		if direction.length_squared() > 4.0:
			aim_direction = direction.normalized()
			_refresh_preview()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_handle_click((event as InputEventMouseButton).position)
	elif event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_1, KEY_2, KEY_3:
				if run_controller != null and run_controller.state.phase == "reward":
					choose_reward(int(event.keycode - KEY_1))
				elif _can_aim():
					power_level = int(event.keycode - KEY_0)
					_refresh_preview()
			KEY_4, KEY_5:
				if _can_aim():
					power_level = int(event.keycode - KEY_0)
					_refresh_preview()
			KEY_SPACE, KEY_ENTER:
				shoot()
			KEY_S:
				settle()
			KEY_K:
				keep()
			KEY_R:
				reset_same_seed()
			KEY_Q:
				use_first_available_tool()
			KEY_TAB:
				if _can_aim():
					assistance_index = (assistance_index + 1) % MODES.size()
					_refresh_preview()
			KEY_LEFT:
				if _can_aim():
					aim_direction = aim_direction.rotated(deg_to_rad(-0.5))
					_refresh_preview()
			KEY_RIGHT:
				if _can_aim():
					aim_direction = aim_direction.rotated(deg_to_rad(0.5))
					_refresh_preview()


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
	queue_redraw()

func reset_same_seed() -> void:
	start_run_same_seed()

func choose_reward(index: int) -> void:
	if run_controller == null or run_controller.state.phase != "reward" or index < 0 or index >= run_controller.state.reward_choices.size():
		return
	var badge_id: String = run_controller.state.reward_choices[index]
	var result := run_controller.choose_reward(badge_id)
	if result.ok:
		controller = run_controller.table_controller
		feedback_text = "已装备「%s」，进入%s" % [BadgeCatalog.get_badge(badge_id).name, RunContent.table_config(run_controller.state.table_index).name]
		_apply_snapshot_positions()
		_refresh_preview()
		queue_redraw()


func shoot() -> void:
	if not _can_aim():
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


func settle() -> void:
	if run_controller == null or controller == null:
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
		queue_redraw()


func keep() -> void:
	if run_controller == null or controller == null:
		return
	var result := run_controller.keep()
	if result.ok:
		feedback_text = LocalizationZhCn.text("feedback.kept")
		feedback_color = Color("8fd7cf")
		_refresh_preview()
		queue_redraw()


func use_first_available_tool() -> void:
	if run_controller == null or controller == null:
		return
	var table := controller.state
	var result := {}
	if int(run_controller.state.tools.get("soft_pocket",0)) > 0 and table.phase == "aiming":
		result = run_controller.use_tool("soft_pocket")
	elif int(run_controller.state.tools.get("color_chalk",0)) > 0 and table.phase == "post_shot_decision":
		for slot: HandSlot in table.hand:
			if slot.has_physical_ball:
				result = run_controller.use_tool("color_chalk", {"ball_id":slot.physical_ball_id,"color_id":"red"})
				break
	elif int(run_controller.state.tools.get("table_reset",0)) > 0 and table.phase == "post_shot_decision":
		result = run_controller.use_tool("table_reset")
		controller = run_controller.table_controller
	if result.get("ok",false):
		feedback_text = "道具已使用"
		_apply_snapshot_positions(); _refresh_preview(); queue_redraw()

func legal_actions() -> Array[String]:
	return controller.allowed_actions() if controller != null else []


func view_model() -> Dictionary:
	if controller == null:
		return {"run_phase": run_controller.state.phase if run_controller != null else "none"}
	var state := controller.state
	return {
		"score": state.score, "target": state.target_score,
		"strokes": state.strokes_remaining, "phase": state.phase,
		"hand": state.hand.map(func(slot: HandSlot) -> Dictionary: return slot.to_dict()),
		"combo": state.combo.duplicate(true), "actions": legal_actions(),
	}


func _handle_click(position: Vector2) -> void:
	if run_controller != null and run_controller.state.phase == "reward":
		for index in run_controller.state.reward_choices.size():
			if Rect2(285 + index * 280, 230, 240, 260).has_point(position): choose_reward(index); return
		return
	if Rect2(1080, 500, 120, 42).has_point(position):
		settle()
	elif Rect2(1210, 500, 110, 42).has_point(position):
		keep()
	elif Rect2(1080, 555, 240, 38).has_point(position):
		reset_same_seed()
	else:
		shoot()


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


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("07111d"))
	draw_string(ThemeDB.fallback_font, Vector2(55, 38), "%s · %s" % [LocalizationZhCn.text("game.title"), LocalizationZhCn.text("screen.tutorial")], HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("dceaf7"))
	draw_string(ThemeDB.fallback_font, Vector2(1040, 38), "M3 · 中文版", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("8fd7cf"))
	draw_rect(TABLE_RECT.grow(12), Color("172638"), true)
	draw_rect(TABLE_RECT, Color("0b493f"), true)
	draw_rect(TABLE_RECT, Color("85a496"), false, 3.0)
	if run_controller != null and run_controller.state.phase == "reward":
		_draw_reward_screen()
	elif run_controller != null and run_controller.state.phase == "won":
		_draw_run_summary()
	elif controller != null:
		_draw_preview()
		_draw_walls()
		_draw_balls()
		_draw_side_panel()
	draw_string(ThemeDB.fallback_font, Vector2(55, 735), feedback_text, HORIZONTAL_ALIGNMENT_LEFT, 700, 18, feedback_color)
	draw_string(ThemeDB.fallback_font, Vector2(700, 735), LocalizationZhCn.text("controls"), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("9db1c4"))


func _draw_reward_screen() -> void:
	draw_string(ThemeDB.fallback_font, Vector2(430, 150), "选择一枚桌边徽章", HORIZONTAL_ALIGNMENT_LEFT, -1, 30, Color("f5cf72"))
	for index in run_controller.state.reward_choices.size():
		var badge := BadgeCatalog.get_badge(run_controller.state.reward_choices[index])
		var rect := Rect2(285 + index * 280, 230, 240, 260)
		draw_rect(rect, Color("13283a"), true)
		draw_rect(rect, Color("8fd7cf"), false, 3)
		draw_string(ThemeDB.fallback_font, rect.position + Vector2(24, 55), "%d · %s" % [index + 1, badge.name], HORIZONTAL_ALIGNMENT_LEFT, 195, 22, Color("dceaf7"))
		draw_string(ThemeDB.fallback_font, rect.position + Vector2(24, 100), "流派：%s" % _build_name(badge.build), HORIZONTAL_ALIGNMENT_LEFT, 195, 16, Color("8fd7cf"))
		draw_string(ThemeDB.fallback_font, rect.position + Vector2(24, 145), "定位：%s" % _role_name(badge.role), HORIZONTAL_ALIGNMENT_LEFT, 195, 16, Color("9db1c4"))
		draw_string(ThemeDB.fallback_font, rect.position + Vector2(24, 220), "点击卡片或按 %d" % [index + 1], HORIZONTAL_ALIGNMENT_LEFT, 195, 14, Color("f5cf72"))

func _draw_run_summary() -> void:
	draw_string(ThemeDB.fallback_font, Vector2(430, 240), "巡回胜利", HORIZONTAL_ALIGNMENT_LEFT, -1, 46, Color("6ff0aa"))
	draw_string(ThemeDB.fallback_font, Vector2(400, 310), "三张球桌全部达标 · 已装备 %d 枚徽章" % run_controller.state.badges.size(), HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("dceaf7"))
	_draw_button(Rect2(500, 390, 260, 50), "相同种子重新开始 [R]", true)

func _build_name(id: String) -> String:
	return {"pure_combo":"纯净组合","rail_chain":"撞库连锁","wall_risk":"功能墙冒险"}.get(id,id)

func _role_name(id: String) -> String:
	return {"starter":"启动器","core":"核心件","amplifier":"放大器","finisher":"收尾件","growth":"成长件"}.get(id,id)

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


func _draw_side_panel() -> void:
	var state := controller.state
	var x := 1080.0
	draw_string(ThemeDB.fallback_font, Vector2(x, 90), "%s  %d" % [LocalizationZhCn.text("hud.target"), state.target_score], HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("9db1c4"))
	draw_string(ThemeDB.fallback_font, Vector2(x, 125), "%s  %d" % [LocalizationZhCn.text("hud.score"), state.score], HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color("f5cf72"))
	draw_string(ThemeDB.fallback_font, Vector2(x, 160), "%s  %d" % [LocalizationZhCn.text("hud.strokes"), state.strokes_remaining], HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("dceaf7"))
	draw_string(ThemeDB.fallback_font, Vector2(x, 205), "%s %d/5" % [LocalizationZhCn.text("hud.hand"), state.hand.size()], HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("8fd7cf"))
	for index in 5:
		var rect := Rect2(x + (index % 3) * 78, 225 + (index / 3) * 75, 66, 60)
		draw_rect(rect, Color("132334"), true)
		draw_rect(rect, Color("f5cf72") if state.combo.participant_indices.has(index) else Color("54677b"), false, 2.0)
		if index < state.hand.size():
			var slot: HandSlot = state.hand[index]
			draw_circle(rect.get_center() - Vector2(0, 7), 16, COLOR_MAP.get(slot.color_id, Color.WHITE))
			draw_string(ThemeDB.fallback_font, rect.get_center() + Vector2(-5, 0), str(slot.number), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("102030"))
			draw_string(ThemeDB.fallback_font, rect.position + Vector2(5, 54), "副本" if not slot.has_physical_ball else "球#%d" % slot.physical_ball_id, HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("9db1c4"))
	draw_string(ThemeDB.fallback_font, Vector2(x, 390), "%s  %s" % [LocalizationZhCn.text("hud.best"), LocalizationZhCn.combo_name(str(state.combo.type))], HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("dceaf7"))
	draw_string(ThemeDB.fallback_font, Vector2(x, 420), "%d × %d = %d" % [state.combo.number_sum, state.combo.multiplier, state.combo.score], HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("f5cf72"))
	_draw_button(Rect2(x, 500, 120, 42), "%s [S]" % LocalizationZhCn.text("action.settle"), legal_actions().has("settle"))
	_draw_button(Rect2(x + 130, 500, 110, 42), "%s [K]" % LocalizationZhCn.text("action.keep"), legal_actions().has("keep"))
	_draw_button(Rect2(x, 555, 240, 38), "%s [R]" % LocalizationZhCn.text("action.reset"), true)
	draw_string(ThemeDB.fallback_font, Vector2(x, 630), "%s %d · %s" % [LocalizationZhCn.text("hud.power"), power_level, LocalizationZhCn.text(MODE_KEYS[assistance_index])], HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("9db1c4"))
	draw_string(ThemeDB.fallback_font, Vector2(x, 655), "%s · %s" % [LocalizationZhCn.text("hud.phase"), LocalizationZhCn.phase_name(state.phase)], HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("9db1c4"))
	var badge_names: Array[String] = []
	for id: String in run_controller.state.badges:
		var badge: Dictionary = BadgeCatalog.get_badge(id)
		badge_names.append(str(badge.get("name", id)))
	draw_string(ThemeDB.fallback_font, Vector2(x, 680), "徽章 · %s" % (" / ".join(badge_names) if not badge_names.is_empty() else "暂无"), HORIZONTAL_ALIGNMENT_LEFT, 250, 11, Color("f5cf72"))
	var tool_names: Array[String] = []
	for id: String in run_controller.state.tools.keys():
		var tool: Dictionary = ToolCatalog.get_tool(id)
		tool_names.append("%s×%d" % [str(tool.get("name", id)), int(run_controller.state.tools[id])])
	draw_string(ThemeDB.fallback_font, Vector2(x, 705), "道具 [Q] · %s" % (" / ".join(tool_names) if not tool_names.is_empty() else "暂无"), HORIZONTAL_ALIGNMENT_LEFT, 250, 11, Color("8fd7cf"))


func _draw_button(rect: Rect2, label: String, enabled: bool) -> void:
	draw_rect(rect, Color("214157") if enabled else Color("17212b"), true)
	draw_rect(rect, Color("8fd7cf") if enabled else Color("44515e"), false, 2.0)
	draw_string(ThemeDB.fallback_font, rect.position + Vector2(10, 27), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("dceaf7") if enabled else Color("657383"))
