class_name TechnicalTable
extends Control

const TABLE_RECT := Rect2(55.0, 75.0, 1000.0, 620.0)
const COLOR_MAP := {
	"red": Color("e85d5d"), "blue": Color("4c86e8"),
	"yellow": Color("e6b94f"), "green": Color("51b977"), "": Color("f2eee4")
}
const MODES := ["concise", "standard", "full"]

var seed := 20260818
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
var feedback_text := "Aim, shoot, then SETTLE or KEEP"
var feedback_color := Color("8fd7cf")

var snapshot: TableSnapshot:
	get: return controller.state.table if controller != null else null


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_ALL
	grab_focus()
	reset_same_seed()
	print("M2_TUTORIAL_READY seed=%d rules=%s" % [seed, CoreLoopSnapshot.RULES_VERSION])


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
			KEY_1, KEY_2, KEY_3, KEY_4, KEY_5:
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


func reset_same_seed() -> void:
	playing = false
	controller = CoreLoopController.new(CoreLoopSnapshot.create_tutorial(seed))
	playback_result = null
	playback_elapsed = 0.0
	feedback_text = "Tutorial reset · build a combo"
	feedback_color = Color("8fd7cf")
	_apply_snapshot_positions()
	_refresh_preview()
	queue_redraw()


func shoot() -> void:
	if not _can_aim():
		return
	var result := controller.shoot(ShotInput.create(1, aim_direction, power_level), true)
	if not result.ok:
		feedback_text = "Shot rejected · %s" % result.code
		feedback_color = Color("ff7a7a")
		return
	playback_result = result.simulation
	playing = true
	playback_elapsed = 0.0
	feedback_text = "Shot playing"
	feedback_color = Color("f5cf72")


func settle() -> void:
	var result := controller.settle()
	if result.ok:
		feedback_text = "SETTLED +%d" % result.banked_score
		feedback_color = Color("f5cf72")
		_set_feedback_from_state()
		_refresh_preview()
		queue_redraw()


func keep() -> void:
	var result := controller.keep()
	if result.ok:
		feedback_text = "KEPT · risk another shot"
		feedback_color = Color("8fd7cf")
		_refresh_preview()
		queue_redraw()


func legal_actions() -> Array[String]:
	return controller.allowed_actions()


func view_model() -> Dictionary:
	var state := controller.state
	return {
		"score": state.score, "target": state.target_score,
		"strokes": state.strokes_remaining, "phase": state.phase,
		"hand": state.hand.map(func(slot: HandSlot) -> Dictionary: return slot.to_dict()),
		"combo": state.combo.duplicate(true), "actions": legal_actions(),
	}


func _handle_click(position: Vector2) -> void:
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
		feedback_text = "TABLE CLEARED · YOU WIN"
		feedback_color = Color("6ff0aa")
	elif state.phase == "lost":
		feedback_text = "OUT OF STROKES · TRY AGAIN"
		feedback_color = Color("ff7a7a")
	elif state.shot_busted:
		feedback_text = "BUST! Sixth slot lost the hand"
		feedback_color = Color("ff6b6b")
	elif state.phase == "post_shot_decision":
		feedback_text = "Choose SETTLE +%d or KEEP" % state.combo.score
		feedback_color = Color("f5cf72")
	else:
		feedback_text = "No collection · aim again"


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("07111d"))
	draw_string(ThemeDB.fallback_font, Vector2(55, 38), "FIVE BALL GRAND SLAM · CORE LOOP TABLE", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("dceaf7"))
	draw_string(ThemeDB.fallback_font, Vector2(1040, 38), "M2 · TUTORIAL", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("8fd7cf"))
	draw_rect(TABLE_RECT.grow(12), Color("172638"), true)
	draw_rect(TABLE_RECT, Color("0b493f"), true)
	draw_rect(TABLE_RECT, Color("85a496"), false, 3.0)
	_draw_preview()
	_draw_walls()
	_draw_balls()
	_draw_side_panel()
	draw_string(ThemeDB.fallback_font, Vector2(55, 735), feedback_text, HORIZONTAL_ALIGNMENT_LEFT, 700, 18, feedback_color)
	draw_string(ThemeDB.fallback_font, Vector2(760, 735), "Click/Space shoot · S settle · K keep · 1–5 power · Tab assist · R reset", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("9db1c4"))


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
		draw_string(ThemeDB.fallback_font, rect.position + Vector2(-8, -8), "COPY %s" % ("●" if wall.charge > 0 else "○") if wall.kind == "copy" else "DYE RED", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, color)


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
	draw_string(ThemeDB.fallback_font, Vector2(x, 90), "TARGET  %d" % state.target_score, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("9db1c4"))
	draw_string(ThemeDB.fallback_font, Vector2(x, 125), "SCORE   %d" % state.score, HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color("f5cf72"))
	draw_string(ThemeDB.fallback_font, Vector2(x, 160), "STROKES %d" % state.strokes_remaining, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("dceaf7"))
	draw_string(ThemeDB.fallback_font, Vector2(x, 205), "HAND %d/5" % state.hand.size(), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("8fd7cf"))
	for index in 5:
		var rect := Rect2(x + (index % 3) * 78, 225 + (index / 3) * 75, 66, 60)
		draw_rect(rect, Color("132334"), true)
		draw_rect(rect, Color("f5cf72") if state.combo.participant_indices.has(index) else Color("54677b"), false, 2.0)
		if index < state.hand.size():
			var slot: HandSlot = state.hand[index]
			draw_circle(rect.get_center() - Vector2(0, 7), 16, COLOR_MAP.get(slot.color_id, Color.WHITE))
			draw_string(ThemeDB.fallback_font, rect.get_center() + Vector2(-5, 0), str(slot.number), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("102030"))
			draw_string(ThemeDB.fallback_font, rect.position + Vector2(5, 54), "COPY" if not slot.has_physical_ball else "#%d" % slot.physical_ball_id, HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("9db1c4"))
	draw_string(ThemeDB.fallback_font, Vector2(x, 390), "BEST  %s" % str(state.combo.type).replace("_", " ").to_upper(), HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("dceaf7"))
	draw_string(ThemeDB.fallback_font, Vector2(x, 420), "%d × %d = %d" % [state.combo.number_sum, state.combo.multiplier, state.combo.score], HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("f5cf72"))
	_draw_button(Rect2(x, 500, 120, 42), "SETTLE [S]", legal_actions().has("settle"))
	_draw_button(Rect2(x + 130, 500, 110, 42), "KEEP [K]", legal_actions().has("keep"))
	_draw_button(Rect2(x, 555, 240, 38), "RESET SAME TABLE [R]", true)
	draw_string(ThemeDB.fallback_font, Vector2(x, 630), "Power %d · %s" % [power_level, MODES[assistance_index]], HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("9db1c4"))
	draw_string(ThemeDB.fallback_font, Vector2(x, 655), "Phase · %s" % state.phase.to_upper(), HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("9db1c4"))


func _draw_button(rect: Rect2, label: String, enabled: bool) -> void:
	draw_rect(rect, Color("214157") if enabled else Color("17212b"), true)
	draw_rect(rect, Color("8fd7cf") if enabled else Color("44515e"), false, 2.0)
	draw_string(ThemeDB.fallback_font, rect.position + Vector2(10, 27), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("dceaf7") if enabled else Color("657383"))
