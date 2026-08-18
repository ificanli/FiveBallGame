class_name FixedStepMotionTest
extends GdUnitTestSuite


func test_free_motion_and_friction_are_monotonic() -> void:
	var snapshot := _single_ball(Vector2(200.0, 200.0), Vector2(300.0, 0.0))
	var simulator := PhysicsSimulator.new()
	var config := PhysicsConfig.default_config()
	var previous_speed := snapshot.balls[0].velocity.length()
	for tick in 30:
		simulator.step_tick(snapshot, config, tick, [])
		var speed := snapshot.balls[0].velocity.length()
		assert_float(speed).is_less_equal(previous_speed)
		previous_speed = speed
	assert_float(snapshot.balls[0].position.x).is_greater(200.0)


func test_simulation_is_independent_of_render_chunking() -> void:
	var initial := _single_ball(Vector2(200.0, 200.0), Vector2.ZERO)
	var shot := ShotInput.create(1, Vector2.RIGHT, 2)
	var simulator := PhysicsSimulator.new()
	var first := simulator.simulate(initial, shot)
	var second := simulator.simulate(initial, shot)
	assert_str(first.state_hash).is_equal(second.state_hash)
	assert_int(first.ticks).is_equal(second.ticks)


func test_low_speed_snaps_to_exact_zero() -> void:
	var snapshot := _single_ball(Vector2(200.0, 200.0), Vector2(1.5, 0.0))
	var result := PhysicsSimulator.new().simulate_existing_motion(snapshot)
	assert_str(result.stop_reason).is_equal("all_stopped")
	assert_vector(result.final_snapshot.balls[0].velocity).is_equal(Vector2.ZERO)
	assert_int(result.ticks).is_less(10)


func test_maximum_duration_uses_bounded_smooth_finish() -> void:
	var snapshot := _single_ball(Vector2(500.0, 310.0), Vector2(4.0, 0.0))
	var config := PhysicsConfig.default_config()
	config.stop_speed = 0.01
	config.low_speed_threshold = 0.02
	config.maximum_shot_seconds = 0.25
	var result := PhysicsSimulator.new().simulate_existing_motion(snapshot, config)
	assert_str(result.stop_reason).is_equal("maximum_duration")
	assert_vector(result.final_snapshot.balls[0].velocity).is_equal(Vector2.ZERO)
	assert_int(result.ticks).is_equal(ceili(config.maximum_shot_seconds / config.fixed_delta))


func test_invalid_shot_does_not_advance_state() -> void:
	var snapshot := _single_ball(Vector2(200.0, 200.0), Vector2.ZERO)
	var before := CanonicalState.hash_value(snapshot.to_dict())
	var result := PhysicsSimulator.new().simulate(snapshot, ShotInput.create(1, Vector2.ZERO, 3))
	assert_str(result.status).is_equal("error")
	assert_str(CanonicalState.hash_value(snapshot.to_dict())).is_equal(before)


func _single_ball(position: Vector2, velocity: Vector2) -> TableSnapshot:
	var snapshot := TableSnapshot.new()
	snapshot.balls.append(BallState.new(1, "cue", 0, "", position, velocity, 18.0))
	return snapshot
