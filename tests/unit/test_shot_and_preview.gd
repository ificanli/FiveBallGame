class_name ShotAndPreviewTest
extends GdUnitTestSuite


func test_all_five_power_levels_map_to_fixed_speeds() -> void:
	var config := PhysicsConfig.default_config()
	for level in range(1, 6):
		var shot := ShotInput.create(1, Vector2.RIGHT, level)
		assert_float(shot.initial_speed(config)).is_equal(config.power_speeds[level - 1])


func test_non_finite_and_zero_directions_are_invalid() -> void:
	assert_bool(ShotInput.create(1, Vector2.ZERO, 3).is_valid()).is_false()
	assert_bool(ShotInput.create(1, Vector2(NAN, 0.0), 3).is_valid()).is_false()
	assert_bool(ShotInput.create(1, Vector2(INF, 0.0), 3).is_valid()).is_false()


func test_repeated_input_serializes_equivalently() -> void:
	var first := ShotInput.create(1, Vector2(3.0, 4.0), 4)
	var second := ShotInput.from_dict(first.to_dict())
	assert_str(CanonicalState.hash_value(first.to_dict())).is_equal(CanonicalState.hash_value(second.to_dict()))


func test_preview_and_full_motion_share_first_collision() -> void:
	var snapshot := _direct_table()
	var shot := ShotInput.create(1, Vector2.RIGHT, 3)
	var service := TrajectoryPreview.new()
	var preview: Dictionary = service.request(snapshot, shot, "standard", 1)
	var actual := PhysicsSimulator.new().simulate(snapshot, shot)
	assert_bool(preview.ok).is_true()
	assert_dict(preview.first_event).is_equal(_first_contact(actual).to_dict())


func test_preview_and_motion_share_function_wall_route() -> void:
	var snapshot := TableSnapshot.new()
	snapshot.balls.append(BallState.new(1, "cue", 0, "", Vector2(150.0, 300.0)))
	snapshot.balls.append(BallState.new(2, "number", 5, "blue", Vector2(280.0, 300.0)))
	snapshot.walls.append(WallState.new(1, "dye", Rect2(500.0, 250.0, 20.0, 100.0), "red", 0))
	var shot := ShotInput.create(1, Vector2.RIGHT, 4)
	var preview: Dictionary = TrajectoryPreview.new().request(snapshot, shot, "full", 1)
	var actual := PhysicsSimulator.new().simulate(snapshot, shot)
	assert_bool(preview.events.any(func(event: Dictionary) -> bool: return event.type == "dye" and event.primary_id == 2)).is_true()
	assert_bool(actual.events.any(func(event: PhysicsEvent) -> bool: return event.type == "dye" and event.primary_id == 2)).is_true()


func test_assistance_budgets_are_ordered_and_do_not_change_input() -> void:
	var snapshot := _direct_table()
	var shot := ShotInput.create(1, Vector2.RIGHT, 3)
	var service := TrajectoryPreview.new()
	var concise: Dictionary = service.request(snapshot, shot, "concise", 1)
	var standard: Dictionary = service.request(snapshot, shot, "standard", 2)
	var full: Dictionary = service.request(snapshot, shot, "full", 3)
	assert_int(concise.tick_budget).is_less(standard.tick_budget)
	assert_int(standard.tick_budget).is_less(full.tick_budget)
	assert_dict(shot.to_dict()).is_equal(ShotInput.create(1, Vector2.RIGHT, 3).to_dict())
	assert_bool(concise.has("recommended_shot")).is_false()


func test_cache_and_stale_request_behavior() -> void:
	var service := TrajectoryPreview.new()
	var snapshot := _direct_table()
	var shot := ShotInput.create(1, Vector2.RIGHT, 3)
	var first: Dictionary = service.request(snapshot, shot, "standard", 10)
	var cached: Dictionary = service.request(snapshot, shot, "standard", 11)
	var stale: Dictionary = service.request(snapshot, shot, "standard", 9)
	assert_bool(first.ok).is_true()
	assert_bool(cached.cache_hit).is_true()
	assert_bool(stale.canceled).is_true()


func _direct_table() -> TableSnapshot:
	var snapshot := TableSnapshot.new()
	snapshot.balls.append(BallState.new(1, "cue", 0, "", Vector2(150.0, 300.0)))
	snapshot.balls.append(BallState.new(2, "number", 3, "red", Vector2(300.0, 300.0)))
	return snapshot


func _first_contact(result: SimulationResult) -> PhysicsEvent:
	for event: PhysicsEvent in result.events:
		if event.type in ["ball_collision", "rail_collision", "wall_collision"]:
			return event
	return null
