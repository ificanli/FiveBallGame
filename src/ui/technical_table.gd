class_name TechnicalTable
extends Control

const TABLE_RECT := Rect2(90.0, 70.0, 1000.0, 620.0)
const COLOR_MAP := {
	"red": Color("e85d5d"), "blue": Color("4c86e8"),
	"yellow": Color("e6b94f"), "green": Color("51b977"), "": Color("f2eee4")
}
const MODES := ["concise", "standard", "full"]

var seed := 20260817
var snapshot: TableSnapshot
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
var last_events: Array[PhysicsEvent] = []
var feedback_text := "Ready"
var feedback_color := Color("8fd7cf")
var stop_reason := "idle"
var last_hash := "—"


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_ALL
	grab_focus()
	reset_same_seed()
	print("TECHNICAL_TABLE_READY seed=%d physics=%s" % [seed, PhysicsConfig.PHYSICS_VERSION])


func _process(delta: float) -> void:
	if playing:
		playback_elapsed += delta
		var tick := mini(playback_result.ticks, int(playback_elapsed / PhysicsConfig.default_config().fixed_delta))
		_apply_playback_tick(tick)
		if tick >= playback_result.ticks:
			playing = false
			snapshot = playback_result.final_snapshot.duplicate_state()
			last_events = playback_result.events.duplicate()
			stop_reason = playback_result.stop_reason
			last_hash = playback_result.state_hash
			_apply_snapshot_positions()
			_set_feedback_from_events()
			_refresh_preview()
		queue_redraw()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and not playing:
		var cue: BallState = snapshot.find_ball(1)
		var mouse_motion := event as InputEventMouseMotion
		var local_table_mouse: Vector2 = mouse_motion.position - TABLE_RECT.position
		var direction: Vector2 = local_table_mouse - cue.position
		if direction.length_squared() > 4.0:
			aim_direction = direction.normalized()
			_refresh_preview()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		shoot()
	elif event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_1, KEY_2, KEY_3, KEY_4, KEY_5:
				if not playing:
					power_level = int(event.keycode - KEY_0)
					feedback_text = "Power %d · %s" % [power_level, _power_name(power_level)]
					_refresh_preview()
			KEY_SPACE, KEY_ENTER:
				shoot()
			KEY_R:
				reset_same_seed()
			KEY_TAB:
				if not playing:
					assistance_index = (assistance_index + 1) % MODES.size()
					feedback_text = "Assist · %s" % MODES[assistance_index]
					_refresh_preview()
			KEY_LEFT:
				if not playing:
					aim_direction = aim_direction.rotated(deg_to_rad(-0.5))
					_refresh_preview()
			KEY_RIGHT:
				if not playing:
					aim_direction = aim_direction.rotated(deg_to_rad(0.5))
					_refresh_preview()


func reset_same_seed() -> void:
	playing = false
	snapshot = TableSnapshot.create_seeded_technical_table(seed)
	playback_result = null
	playback_elapsed = 0.0
	last_events.clear()
	stop_reason = "idle"
	last_hash = CanonicalState.hash_value(snapshot.to_dict())
	feedback_text = "Same-seed table reset"
	feedback_color = Color("8fd7cf")
	_apply_snapshot_positions()
	_refresh_preview()
	queue_redraw()


func shoot() -> void:
	if playing:
		return
	var shot := ShotInput.create(1, aim_direction, power_level)
	playback_result = PhysicsSimulator.new().simulate(snapshot, shot, null, -1, true)
	if playback_result.status != "success":
		feedback_text = "Shot rejected: %s" % playback_result.error.get("code", "error")
		feedback_color = Color("ff7a7a")
		return
	playing = true
	playback_elapsed = 0.0
	feedback_text = "Shot playing"
	feedback_color = Color("f5cf72")


func _refresh_preview() -> void:
	if playing or snapshot == null:
		return
	preview_request_id += 1
	preview = preview_service.request(snapshot, ShotInput.create(1, aim_direction, power_level), MODES[assistance_index], preview_request_id)
	queue_redraw()


func _apply_snapshot_positions() -> void:
	display_positions.clear()
	for ball: BallState in snapshot.balls:
		display_positions[ball.id] = ball.position


func _apply_playback_tick(tick: int) -> void:
	if playback_result == null:
		return
	for id_text: Variant in playback_result.trajectories:
		var samples: Array = playback_result.trajectories[id_text]
		if samples.is_empty():
			continue
		var index := mini(tick, samples.size() - 1)
		var position_data: Dictionary = samples[index].position
		display_positions[int(id_text)] = Vector2(float(position_data.x), float(position_data.y))


func _set_feedback_from_events() -> void:
	var copies := last_events.filter(func(event: PhysicsEvent) -> bool: return event.type == "copy")
	var dyes := last_events.filter(func(event: PhysicsEvent) -> bool: return event.type == "dye")
	if not dyes.is_empty():
		feedback_text = "DYE · ball %d · %s → %s" % [dyes[-1].primary_id, dyes[-1].data.old_color_id, dyes[-1].data.new_color_id]
		feedback_color = Color("ff7777")
	elif not copies.is_empty():
		feedback_text = "COPY · ball %d · %s %d" % [copies[-1].primary_id, copies[-1].data.color_id, copies[-1].data.number]
		feedback_color = Color("55ddd2")
	else:
		feedback_text = "Shot ended · %s" % stop_reason
		feedback_color = Color("b8c7d9")


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("07111d"))
	_draw_header()
	_draw_table()
	_draw_preview()
	_draw_walls()
	_draw_balls()
	_draw_debug_panel()
	_draw_footer()


func _draw_header() -> void:
	draw_string(ThemeDB.fallback_font, Vector2(90, 38), "FIVE BALL GRAND SLAM · DETERMINISTIC TECH TABLE", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("dceaf7"))
	draw_string(ThemeDB.fallback_font, Vector2(900, 38), "M1 · NOT GAMEPLAY COMPLETE", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("7f93a8"))


func _draw_table() -> void:
	draw_rect(TABLE_RECT.grow(12), Color("172638"), true)
	draw_rect(TABLE_RECT, Color("0b493f"), true)
	draw_rect(TABLE_RECT, Color("85a496"), false, 3.0)


func _draw_preview() -> void:
	if playing or not preview.get("ok", false):
		return
	var trajectories: Dictionary = preview.get("trajectories", {})
	for id_text: Variant in trajectories:
		var samples: Array = trajectories[id_text]
		if samples.size() < 2:
			continue
		var points := PackedVector2Array()
		var stride := 2 if MODES[assistance_index] == "full" else 1
		for index in range(0, samples.size(), stride):
			var position_data: Dictionary = samples[index].position
			points.append(TABLE_RECT.position + Vector2(float(position_data.x), float(position_data.y)))
		var color := Color(1, 1, 1, 0.65) if int(id_text) == 1 else Color(0.4, 0.95, 0.88, 0.4)
		draw_polyline(points, color, 2.0, true)
	var cue: BallState = snapshot.find_ball(1)
	draw_line(TABLE_RECT.position + cue.position, TABLE_RECT.position + cue.position + aim_direction * 75.0, Color("ffffff"), 3.0)


func _draw_walls() -> void:
	for wall: WallState in snapshot.walls:
		var rect := Rect2(TABLE_RECT.position + wall.rect.position, wall.rect.size)
		var color: Color = Color("49d4ca") if wall.kind == "copy" else COLOR_MAP.get(wall.color_id, Color.WHITE)
		draw_rect(rect, color, true)
		draw_rect(rect, Color.WHITE, false, 2.0)
		draw_string(ThemeDB.fallback_font, rect.position + Vector2(-4, -8), "COPY ●" if wall.kind == "copy" and wall.charge > 0 else ("COPY ○" if wall.kind == "copy" else "DYE %s" % wall.color_id.to_upper()), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, color)


func _draw_balls() -> void:
	for ball: BallState in snapshot.balls:
		var center: Vector2 = TABLE_RECT.position + display_positions.get(ball.id, ball.position)
		var color: Color = COLOR_MAP.get(ball.color_id, Color.WHITE)
		draw_circle(center, ball.radius, color)
		draw_circle(center, ball.radius, Color.WHITE if ball.active else Color("1b2734"), false, 3.0 if ball.active else 1.5)
		var label := "C" if ball.kind == "cue" else str(ball.number)
		draw_string(ThemeDB.fallback_font, center + Vector2(-7, 6), label, HORIZONTAL_ALIGNMENT_CENTER, 14, 16, Color("102030"))
		draw_string(ThemeDB.fallback_font, center + Vector2(-14, -24), "#%d" % ball.id, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("d8e8ef"))


func _draw_debug_panel() -> void:
	var x := 1115.0
	draw_string(ThemeDB.fallback_font, Vector2(x, 82), "DEBUG", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("f5cf72"))
	var lines := [
		"Seed: %d" % seed,
		"Physics: %s" % PhysicsConfig.PHYSICS_VERSION,
		"Revision: %d" % snapshot.revision,
		"Power: %d / %s" % [power_level, _power_name(power_level)],
		"Assist: %s" % MODES[assistance_index],
		"Angle: %.2f°" % rad_to_deg(aim_direction.angle()),
		"State: %s" % ("PLAYING" if playing else "AIM"),
		"Stop: %s" % stop_reason,
		"Hash: %s" % last_hash.left(12),
		"Events: %d" % last_events.size(),
	]
	for index in lines.size():
		draw_string(ThemeDB.fallback_font, Vector2(x, 112 + index * 23), lines[index], HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("b8c7d9"))
	draw_string(ThemeDB.fallback_font, Vector2(x, 365), "BALLS", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("8fd7cf"))
	var row := 0
	for ball: BallState in snapshot.balls:
		var speed := ball.velocity.length()
		draw_string(ThemeDB.fallback_font, Vector2(x, 390 + row * 24), "#%d %s n%d %s v%.1f src%d" % [ball.id, ball.kind.left(1), ball.number, ball.color_id, speed, ball.activation_source_id], HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("9db1c4"))
		row += 1


func _draw_footer() -> void:
	draw_string(ThemeDB.fallback_font, Vector2(90, 730), feedback_text, HORIZONTAL_ALIGNMENT_LEFT, 650, 18, feedback_color)
	draw_string(ThemeDB.fallback_font, Vector2(760, 730), "Mouse aim · Click/Space shoot · 1–5 power · Tab assist · ←/→ fine aim · R reset", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("9db1c4"))


func _power_name(level: int) -> String:
	return ["", "Light push", "Soft hit", "Standard", "Strong", "Full power"][level]
