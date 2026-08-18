class_name WallEffectResolver
extends RefCounted


func reset_for_new_shot(state: TableSnapshot) -> void:
	for ball: BallState in state.balls:
		if ball.kind == "number":
			ball.active = false
			ball.activation_source_id = 0
	for wall: WallState in state.walls:
		wall.charge = wall.maximum_charge


func process_event(state: TableSnapshot, event: PhysicsEvent, output: Array) -> void:
	if event.type == "ball_collision":
		_process_ball_collision(state, event, output)
	elif event.type == "wall_collision":
		_process_wall_collision(state, event, output)


func _process_ball_collision(state: TableSnapshot, event: PhysicsEvent, output: Array) -> void:
	var first := state.find_ball(event.primary_id)
	var second := state.find_ball(event.secondary_id)
	if first == null or second == null:
		return
	if first.kind == "cue" and second.kind == "number":
		_activate(second, first.id, event.tick, output)
	elif second.kind == "cue" and first.kind == "number":
		_activate(first, second.id, event.tick, output)
	elif first.kind == "number" and second.kind == "number":
		if first.active and not second.active:
			_activate(second, first.id, event.tick, output)
		elif second.active and not first.active:
			_activate(first, second.id, event.tick, output)


func _activate(ball: BallState, source_id: int, tick: int, output: Array) -> void:
	if ball.active:
		return
	ball.active = true
	ball.activation_source_id = source_id
	output.append(PhysicsEvent.rule_event("activation", tick, ball.id, 0, {"source_id": source_id}))


func _process_wall_collision(state: TableSnapshot, event: PhysicsEvent, output: Array) -> void:
	var ball := state.find_ball(event.primary_id)
	var wall := _find_wall(state, event.secondary_id)
	if ball == null or wall == null or ball.kind != "number" or not ball.active:
		return
	if wall.kind == "copy" and wall.charge > 0:
		wall.charge -= 1
		output.append(PhysicsEvent.rule_event("copy", event.tick, ball.id, wall.id, {
			"number": ball.number,
			"color_id": ball.color_id,
			"remaining_charge": wall.charge,
		}))
	elif wall.kind == "dye" and ball.color_id != wall.color_id:
		var old_color := ball.color_id
		ball.color_id = wall.color_id
		output.append(PhysicsEvent.rule_event("dye", event.tick, ball.id, wall.id, {
			"old_color_id": old_color,
			"new_color_id": wall.color_id,
			"number": ball.number,
		}))


func _find_wall(state: TableSnapshot, wall_id: int) -> WallState:
	for wall: WallState in state.walls:
		if wall.id == wall_id:
			return wall
	return null
