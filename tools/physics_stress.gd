extends SceneTree

const ANGLES := [-35.0, -20.0, -8.0, 0.0, 8.0, 20.0, 35.0]
const REPEATS := 100


func _init() -> void:
	var started := Time.get_ticks_usec()
	var failures: Array[Dictionary] = []
	var cases_run := 0
	for angle_degrees: float in ANGLES:
		var snapshot := _make_stress_table(angle_degrees)
		var direction := Vector2.RIGHT.rotated(deg_to_rad(angle_degrees))
		var shot := ShotInput.create(1, direction, 5)
		var baseline := PhysicsSimulator.new().simulate(snapshot, shot)
		cases_run += 1
		_validate_result("angle_%s" % angle_degrees, baseline, failures)
		for repeat_index in REPEATS:
			var repeated := PhysicsSimulator.new().simulate(snapshot, shot)
			if repeated.state_hash != baseline.state_hash or repeated.ticks != baseline.ticks:
				failures.append({
					"case": "angle_%s" % angle_degrees,
					"repeat": repeat_index,
					"reason": "determinism",
					"expected_hash": baseline.state_hash,
					"actual_hash": repeated.state_hash,
				})
				break
	var elapsed_milliseconds := (Time.get_ticks_usec() - started) / 1000.0
	var output := {
		"status": "passed" if failures.is_empty() else "failed",
		"cases": cases_run,
		"repeats_per_case": REPEATS,
		"elapsed_ms": elapsed_milliseconds,
		"failures": failures,
	}
	print(JSON.stringify(output))
	quit(0 if failures.is_empty() else 1)


func _make_stress_table(angle_degrees: float) -> TableSnapshot:
	var snapshot := TableSnapshot.new()
	var direction := Vector2.RIGHT.rotated(deg_to_rad(angle_degrees))
	var cue_position := Vector2(150.0, 310.0)
	snapshot.balls.append(BallState.new(1, "cue", 0, "", cue_position))
	for index in 6:
		var distance := 95.0 + index * 52.0
		var lateral := (index % 2) * 10.0 - 5.0
		var position := cue_position + direction * distance + direction.orthogonal() * lateral
		snapshot.balls.append(BallState.new(index + 2, "number", index + 1, "red", position))
	return snapshot


func _validate_result(case_id: String, result: SimulationResult, failures: Array[Dictionary]) -> void:
	if result.status != "success":
		failures.append({"case": case_id, "reason": result.status, "error": result.error})
		return
	for ball: BallState in result.final_snapshot.balls:
		if not ball.position.is_finite() or not ball.velocity.is_finite():
			failures.append({"case": case_id, "reason": "non_finite", "ball_id": ball.id})
	for first_index in result.final_snapshot.balls.size():
		for second_index in range(first_index + 1, result.final_snapshot.balls.size()):
			var first: BallState = result.final_snapshot.balls[first_index]
			var second: BallState = result.final_snapshot.balls[second_index]
			if first.position.distance_to(second.position) < first.radius + second.radius - 0.01:
				failures.append({"case": case_id, "reason": "overlap", "balls": [first.id, second.id]})
