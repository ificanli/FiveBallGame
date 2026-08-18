class_name WallEffectsTest
extends GdUnitTestSuite


func test_cue_activates_number_and_records_source() -> void:
	var snapshot := _table_with_balls([
		BallState.new(1, "cue", 0, "", Vector2(200.0, 300.0)),
		BallState.new(2, "number", 3, "red", Vector2(260.0, 300.0)),
	])
	var result := PhysicsSimulator.new().simulate(snapshot, ShotInput.create(1, Vector2.RIGHT, 3))
	var target := result.final_snapshot.find_ball(2)
	assert_bool(target.active).is_true()
	assert_int(target.activation_source_id).is_equal(1)
	assert_bool(_has_event(result, "activation", 2)).is_true()


func test_active_number_propagates_activation_in_stable_order() -> void:
	var snapshot := _table_with_balls([
		BallState.new(1, "cue", 0, "", Vector2(160.0, 300.0)),
		BallState.new(2, "number", 3, "red", Vector2(240.0, 300.0)),
		BallState.new(3, "number", 4, "blue", Vector2(320.0, 300.0)),
	])
	var result := PhysicsSimulator.new().simulate(snapshot, ShotInput.create(1, Vector2.RIGHT, 4))
	assert_bool(result.final_snapshot.find_ball(2).active).is_true()
	assert_bool(result.final_snapshot.find_ball(3).active).is_true()
	assert_int(result.final_snapshot.find_ball(3).activation_source_id).is_equal(2)
	var activations := result.events.filter(func(event: PhysicsEvent) -> bool: return event.type == "activation")
	assert_array(activations.map(func(event: PhysicsEvent) -> int: return event.primary_id)).contains_exactly([2, 3])


func test_inactive_number_hitting_function_wall_only_reflects() -> void:
	var ball := BallState.new(2, "number", 3, "red", Vector2(450.0, 300.0), Vector2(500.0, 0.0))
	var snapshot := _table_with_balls([ball])
	snapshot.walls.append(WallState.new(1, "copy", Rect2(520.0, 250.0, 20.0, 100.0), "", 1))
	var result := PhysicsSimulator.new().simulate_existing_motion(snapshot)
	assert_bool(_has_event(result, "wall_collision", 2)).is_true()
	assert_bool(_has_event(result, "copy", 2)).is_false()


func test_active_number_consumes_copy_charge_once() -> void:
	var ball := BallState.new(2, "number", 7, "yellow", Vector2(450.0, 300.0), Vector2(500.0, 0.0))
	ball.active = true
	ball.activation_source_id = 1
	var snapshot := _table_with_balls([ball])
	snapshot.walls.append(WallState.new(1, "copy", Rect2(520.0, 250.0, 20.0, 100.0), "", 1))
	var result := PhysicsSimulator.new().simulate_existing_motion(snapshot)
	var copies := result.events.filter(func(event: PhysicsEvent) -> bool: return event.type == "copy")
	assert_int(copies.size()).is_equal(1)
	assert_int(copies[0].primary_id).is_equal(2)
	assert_int(copies[0].data.number).is_equal(7)
	assert_str(copies[0].data.color_id).is_equal("yellow")
	assert_int(result.final_snapshot.walls[0].charge).is_equal(0)


func test_cue_never_triggers_copy_or_dye() -> void:
	var snapshot := _table_with_balls([BallState.new(1, "cue", 0, "", Vector2(450.0, 300.0))])
	snapshot.walls.append(WallState.new(1, "copy", Rect2(520.0, 250.0, 20.0, 100.0), "", 1))
	var result := PhysicsSimulator.new().simulate(snapshot, ShotInput.create(1, Vector2.RIGHT, 3))
	assert_bool(_has_event(result, "copy", 1)).is_false()
	assert_int(result.final_snapshot.walls[0].charge).is_equal(1)


func test_dye_targets_actual_impacting_active_ball_and_preserves_number() -> void:
	var first := BallState.new(2, "number", 5, "blue", Vector2(450.0, 270.0), Vector2(500.0, 0.0))
	first.active = true
	first.activation_source_id = 1
	var other := BallState.new(3, "number", 8, "green", Vector2(350.0, 430.0))
	other.active = true
	other.activation_source_id = 1
	var snapshot := _table_with_balls([first, other])
	snapshot.walls.append(WallState.new(1, "dye", Rect2(520.0, 220.0, 20.0, 100.0), "red", 0))
	var result := PhysicsSimulator.new().simulate_existing_motion(snapshot)
	assert_str(result.final_snapshot.find_ball(2).color_id).is_equal("red")
	assert_int(result.final_snapshot.find_ball(2).number).is_equal(5)
	assert_str(result.final_snapshot.find_ball(3).color_id).is_equal("green")
	var dye_events := result.events.filter(func(event: PhysicsEvent) -> bool: return event.type == "dye")
	assert_int(dye_events.size()).is_equal(1)
	assert_int(dye_events[0].primary_id).is_equal(2)
	assert_str(dye_events[0].data.old_color_id).is_equal("blue")
	assert_str(dye_events[0].data.new_color_id).is_equal("red")


func test_new_simulation_resets_copy_charge() -> void:
	var snapshot := _table_with_balls([BallState.new(1, "cue", 0, "", Vector2(200.0, 300.0))])
	var wall := WallState.new(1, "copy", Rect2(700.0, 250.0, 20.0, 100.0), "", 1)
	wall.charge = 0
	snapshot.walls.append(wall)
	var result := PhysicsSimulator.new().simulate(snapshot, ShotInput.create(1, Vector2.RIGHT, 1))
	assert_int(result.final_snapshot.walls[0].charge).is_equal(1)


func _table_with_balls(items: Array[BallState]) -> TableSnapshot:
	var snapshot := TableSnapshot.new()
	snapshot.balls.assign(items)
	return snapshot


func _has_event(result: SimulationResult, type: String, primary_id: int) -> bool:
	return result.events.any(func(event: PhysicsEvent) -> bool: return event.type == type and event.primary_id == primary_id)
