class_name ReplayRunner
extends RefCounted


func execute_case(case_data: Dictionary) -> Dictionary:
	var validation := ReplayCodec.validate_case(case_data)
	if not validation.valid:
		return {
			"case_id": str(case_data.get("case_id", "unknown")),
			"status": "validation_error",
			"errors": validation.errors,
		}
	var replay := ReplayCase.from_dict(case_data)
	var result := PhysicsSimulator.new().simulate(replay.initial_snapshot, replay.shot_input)
	return _result_payload(replay.case_id, result)


func compare_case(case_data: Dictionary) -> Dictionary:
	var actual := execute_case(case_data)
	if actual.status != "success":
		return {"passed": false, "case_id": actual.case_id, "actual": actual, "difference": {"path": "$.status"}}
	var expected: Dictionary = case_data.get("expected", {})
	if expected.is_empty():
		return {"passed": false, "case_id": actual.case_id, "actual": actual, "difference": {"path": "$.expected", "reason": "missing_golden"}}
	var comparable_actual := comparable_output(actual)
	var difference := CanonicalState.first_difference(expected, comparable_actual)
	return {
		"passed": difference.equal,
		"case_id": actual.case_id,
		"actual": actual,
		"difference": difference,
	}


func comparable_output(actual: Dictionary) -> Dictionary:
	return {
		"status": actual.status,
		"events": actual.events,
		"final_ball_states": actual.final_ball_states,
		"wall_states": actual.wall_states,
		"ticks": actual.ticks,
		"stop_reason": actual.stop_reason,
		"state_hash": actual.state_hash,
	}


func _result_payload(case_id: String, result: SimulationResult) -> Dictionary:
	var event_data: Array[Dictionary] = []
	for event: PhysicsEvent in result.events:
		event_data.append(event.to_dict())
	var balls: Array[Dictionary] = []
	var walls: Array[Dictionary] = []
	if result.final_snapshot != null:
		for ball: BallState in result.final_snapshot.balls:
			balls.append(ball.to_dict())
		for wall: WallState in result.final_snapshot.walls:
			walls.append(wall.to_dict())
	return {
		"case_id": case_id,
		"status": result.status,
		"events": event_data,
		"final_ball_states": balls,
		"wall_states": walls,
		"ticks": result.ticks,
		"stop_reason": result.stop_reason,
		"state_hash": result.state_hash,
		"error": result.error,
	}
