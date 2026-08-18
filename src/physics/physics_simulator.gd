class_name PhysicsSimulator
extends RefCounted

const POSITION_EPSILON := 0.0001


func simulate(initial: TableSnapshot, shot: ShotInput, config: PhysicsConfig = null) -> SimulationResult:
	var used_config := config if config != null else PhysicsConfig.default_config()
	var result := SimulationResult.new()
	if not shot.is_valid():
		result.status = "error"
		result.error = {"code": "invalid_shot_input"}
		return result
	var state := initial.duplicate_state()
	var cue := state.find_ball(shot.cue_ball_id)
	if cue == null or cue.kind != "cue":
		result.status = "error"
		result.error = {"code": "invalid_cue_ball_id", "id": shot.cue_ball_id}
		return result
	WallEffectResolver.new().reset_for_new_shot(state)
	cue.velocity = shot.direction * used_config.power_speed(shot.power_level)
	return _run(state, used_config)


func simulate_existing_motion(initial: TableSnapshot, config: PhysicsConfig = null) -> SimulationResult:
	return _run(initial.duplicate_state(), config if config != null else PhysicsConfig.default_config())


func _run(state: TableSnapshot, config: PhysicsConfig) -> SimulationResult:
	var result := SimulationResult.new()
	result.status = "success"
	var maximum_ticks := ceili(config.maximum_shot_seconds / config.fixed_delta)
	var finish_ticks := maxi(1, ceili(config.low_speed_finish_seconds / config.fixed_delta))
	var low_speed_ticks := 0
	var timeout_finish_start := maxi(0, maximum_ticks - finish_ticks)
	for tick in maximum_ticks:
		if _all_stopped(state, config.stop_speed) and tick < timeout_finish_start:
			_zero_all(state)
			result.ticks = tick
			result.stop_reason = "all_stopped"
			return _finish_result(result, state)
		step_tick(state, config, tick, result.events)
		if _all_below(state, config.low_speed_threshold):
			low_speed_ticks += 1
			_apply_finish_damping(state, low_speed_ticks, finish_ticks)
		else:
			low_speed_ticks = 0
		if tick >= timeout_finish_start:
			_apply_finish_damping(state, tick - timeout_finish_start + 1, finish_ticks)
		if not _state_is_finite(state):
			result.status = "error"
			result.ticks = tick + 1
			result.stop_reason = "non_finite"
			result.error = {"code": "non_finite_state", "tick": tick + 1}
			return _finish_result(result, state)
	result.ticks = maximum_ticks
	result.stop_reason = "maximum_duration"
	_zero_all(state)
	return _finish_result(result, state)


func step_tick(state: TableSnapshot, config: PhysicsConfig, tick: int, events: Array) -> void:
	var substeps := _substep_count(state, config)
	var sub_delta := config.fixed_delta / float(substeps)
	var pair_contacts := {}
	var rail_contacts := {}
	var wall_contacts := {}
	var resolver := WallEffectResolver.new()
	for substep in substeps:
		for ball: BallState in state.balls:
			ball.position += ball.velocity * sub_delta
		_resolve_rails(state, config, tick, events, rail_contacts)
		_resolve_internal_walls(state, config, tick, events, wall_contacts, resolver)
		for _iteration in 2:
			_resolve_ball_pairs(state, config, tick, events, pair_contacts, resolver)
	for ball: BallState in state.balls:
		ball.velocity *= config.drag_per_tick
		if ball.velocity.length() < config.stop_speed:
			ball.velocity = Vector2.ZERO
	state.revision += 1


func _substep_count(state: TableSnapshot, config: PhysicsConfig) -> int:
	var maximum_speed := 0.0
	var minimum_radius := INF
	for ball: BallState in state.balls:
		maximum_speed = maxf(maximum_speed, ball.velocity.length())
		minimum_radius = minf(minimum_radius, ball.radius)
	if state.balls.is_empty() or maximum_speed <= 0.0:
		return 1
	var maximum_displacement := maxf(minimum_radius * 0.5, 1.0)
	return clampi(ceili(maximum_speed * config.fixed_delta / maximum_displacement), 1, config.maximum_substeps)


func _resolve_ball_pairs(
	state: TableSnapshot,
	config: PhysicsConfig,
	tick: int,
	events: Array,
	contacts: Dictionary,
	resolver: WallEffectResolver
) -> void:
	var candidates := _collect_pair_candidates(state)
	for pair: Array in candidates:
		var first: BallState = pair[0]
		var second: BallState = pair[1]
		var delta := second.position - first.position
		var distance_squared := delta.length_squared()
		var minimum_distance := first.radius + second.radius
		if distance_squared > minimum_distance * minimum_distance:
			continue
		var distance := sqrt(maxf(distance_squared, 0.0))
		var normal := delta / distance if distance > POSITION_EPSILON else _fallback_normal(first.id, second.id)
		var overlap := minimum_distance - distance
		if overlap > 0.0:
			var correction := normal * (overlap * 0.5 + POSITION_EPSILON)
			first.position -= correction
			second.position += correction
		var relative_normal_speed := (second.velocity - first.velocity).dot(normal)
		if relative_normal_speed < 0.0:
			var impulse_magnitude := -(1.0 + config.ball_restitution) * relative_normal_speed * 0.5
			var impulse := normal * impulse_magnitude
			first.velocity -= impulse
			second.velocity += impulse
		var key := "%d:%d" % [first.id, second.id]
		if not contacts.has(key):
			contacts[key] = true
			var event := PhysicsEvent.ball_collision(tick, first.id, second.id, (first.position + second.position) * 0.5)
			events.append(event)
			resolver.process_event(state, event, events)


func _collect_pair_candidates(state: TableSnapshot) -> Array[Array]:
	var by_x := state.balls.duplicate()
	by_x.sort_custom(func(left: BallState, right: BallState) -> bool:
		if not is_equal_approx(left.position.x, right.position.x):
			return left.position.x < right.position.x
		return left.id < right.id
	)
	var candidates: Array[Array] = []
	for first_index in by_x.size():
		var first: BallState = by_x[first_index]
		for second_index in range(first_index + 1, by_x.size()):
			var second: BallState = by_x[second_index]
			if second.position.x - second.radius > first.position.x + first.radius:
				break
			if absf(second.position.y - first.position.y) <= first.radius + second.radius:
				var ordered_pair: Array = [first, second] if first.id < second.id else [second, first]
				candidates.append(ordered_pair)
	candidates.sort_custom(func(left: Array, right: Array) -> bool:
		var left_first: BallState = left[0]
		var right_first: BallState = right[0]
		if left_first.id != right_first.id:
			return left_first.id < right_first.id
		var left_second: BallState = left[1]
		var right_second: BallState = right[1]
		return left_second.id < right_second.id
	)
	return candidates


func _resolve_internal_walls(
	state: TableSnapshot,
	config: PhysicsConfig,
	tick: int,
	events: Array,
	contacts: Dictionary,
	resolver: WallEffectResolver
) -> void:
	var ordered_balls := state.balls.duplicate()
	ordered_balls.sort_custom(func(left: BallState, right: BallState) -> bool: return left.id < right.id)
	var ordered_walls := state.walls.duplicate()
	ordered_walls.sort_custom(func(left: WallState, right: WallState) -> bool: return left.id < right.id)
	for ball: BallState in ordered_balls:
		for wall: WallState in ordered_walls:
			var closest := Vector2(
				clampf(ball.position.x, wall.rect.position.x, wall.rect.end.x),
				clampf(ball.position.y, wall.rect.position.y, wall.rect.end.y)
			)
			var delta := ball.position - closest
			if delta.length_squared() >= ball.radius * ball.radius:
				continue
			var normal := _wall_normal(ball, wall, delta)
			var distance := delta.length()
			ball.position += normal * (ball.radius - distance + POSITION_EPSILON)
			var normal_speed := ball.velocity.dot(normal)
			if normal_speed < 0.0:
				ball.velocity -= normal * (1.0 + config.rail_restitution) * normal_speed
			var key := "%d:%d" % [ball.id, wall.id]
			if not contacts.has(key):
				contacts[key] = true
				var event := PhysicsEvent.wall_collision(tick, ball.id, wall.id, closest)
				events.append(event)
				resolver.process_event(state, event, events)


func _wall_normal(ball: BallState, wall: WallState, delta: Vector2) -> Vector2:
	if delta.length_squared() > POSITION_EPSILON * POSITION_EPSILON:
		return delta.normalized()
	var distances := [
		{"distance": absf(ball.position.x - wall.rect.position.x), "normal": Vector2.LEFT, "order": 0},
		{"distance": absf(wall.rect.end.x - ball.position.x), "normal": Vector2.RIGHT, "order": 1},
		{"distance": absf(ball.position.y - wall.rect.position.y), "normal": Vector2.UP, "order": 2},
		{"distance": absf(wall.rect.end.y - ball.position.y), "normal": Vector2.DOWN, "order": 3},
	]
	distances.sort_custom(func(left: Dictionary, right: Dictionary) -> bool:
		if not is_equal_approx(left.distance, right.distance):
			return left.distance < right.distance
		return left.order < right.order
	)
	return distances[0].normal


func _resolve_rails(
	state: TableSnapshot,
	config: PhysicsConfig,
	tick: int,
	events: Array,
	contacts: Dictionary
) -> void:
	var ordered := state.balls.duplicate()
	ordered.sort_custom(func(left: BallState, right: BallState) -> bool: return left.id < right.id)
	for ball: BallState in ordered:
		var minimum := state.bounds.position + Vector2.ONE * ball.radius
		var maximum := state.bounds.end - Vector2.ONE * ball.radius
		_resolve_single_rail(ball, "left", ball.position.x < minimum.x, Vector2.RIGHT, Vector2(minimum.x, ball.position.y), config, tick, events, contacts)
		_resolve_single_rail(ball, "right", ball.position.x > maximum.x, Vector2.LEFT, Vector2(maximum.x, ball.position.y), config, tick, events, contacts)
		_resolve_single_rail(ball, "top", ball.position.y < minimum.y, Vector2.DOWN, Vector2(ball.position.x, minimum.y), config, tick, events, contacts)
		_resolve_single_rail(ball, "bottom", ball.position.y > maximum.y, Vector2.UP, Vector2(ball.position.x, maximum.y), config, tick, events, contacts)
		ball.position.x = clampf(ball.position.x, minimum.x, maximum.x)
		ball.position.y = clampf(ball.position.y, minimum.y, maximum.y)


func _resolve_single_rail(
	ball: BallState,
	rail_name: String,
	is_penetrating: bool,
	inward_normal: Vector2,
	contact_point: Vector2,
	config: PhysicsConfig,
	tick: int,
	events: Array,
	contacts: Dictionary
) -> void:
	if not is_penetrating:
		return
	var normal_speed := ball.velocity.dot(inward_normal)
	if normal_speed < 0.0:
		ball.velocity -= inward_normal * (1.0 + config.rail_restitution) * normal_speed
	var key := "%d:%s" % [ball.id, rail_name]
	if not contacts.has(key):
		contacts[key] = true
		events.append(PhysicsEvent.rail_collision(tick, ball.id, rail_name, contact_point))


func _fallback_normal(first_id: int, second_id: int) -> Vector2:
	return Vector2.RIGHT if first_id < second_id else Vector2.LEFT


func _all_stopped(state: TableSnapshot, threshold: float) -> bool:
	return _all_below(state, threshold)


func _all_below(state: TableSnapshot, threshold: float) -> bool:
	for ball: BallState in state.balls:
		if ball.velocity.length() >= threshold:
			return false
	return true


func _apply_finish_damping(state: TableSnapshot, progress_ticks: int, total_ticks: int) -> void:
	var remaining := clampf(1.0 - float(progress_ticks) / float(total_ticks), 0.0, 1.0)
	for ball: BallState in state.balls:
		ball.velocity *= remaining


func _zero_all(state: TableSnapshot) -> void:
	for ball: BallState in state.balls:
		ball.velocity = Vector2.ZERO


func _state_is_finite(state: TableSnapshot) -> bool:
	for ball: BallState in state.balls:
		if not ball.position.is_finite() or not ball.velocity.is_finite():
			return false
	return true


func _finish_result(result: SimulationResult, state: TableSnapshot) -> SimulationResult:
	result.final_snapshot = state
	result.state_hash = CanonicalState.hash_value({
		"events": result.events.map(func(event: PhysicsEvent) -> Dictionary: return event.to_dict()),
		"final_snapshot": state.to_dict(),
		"ticks": result.ticks,
		"stop_reason": result.stop_reason,
	})
	return result
