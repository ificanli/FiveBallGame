class_name PhysicsDataModelTest
extends GdUnitTestSuite


func test_stable_id_allocator_is_monotonic() -> void:
	var ids := StableIdAllocator.new(10)
	assert_array([ids.next_id(), ids.next_id(), ids.next_id()]).contains_exactly([10, 11, 12])


func test_seeded_snapshot_generation_is_reproducible() -> void:
	var first := TableSnapshot.create_seeded_technical_table(20260817)
	var second := TableSnapshot.create_seeded_technical_table(20260817)
	assert_str(CanonicalState.hash_value(first.to_dict())).is_equal(CanonicalState.hash_value(second.to_dict()))
	assert_int(first.balls.size()).is_equal(7)
	assert_str(first.balls[0].kind).is_equal("cue")
	assert_int(first.balls[0].number).is_equal(0)
	assert_str(first.balls[0].color_id).is_empty()


func test_data_model_round_trip() -> void:
	var original := TableSnapshot.create_seeded_technical_table(42)
	var decoded := TableSnapshot.from_dict(original.to_dict())
	assert_dict(decoded.to_dict()).is_equal(original.to_dict())


func test_shot_input_round_trip_and_fixed_power() -> void:
	var shot := ShotInput.create(1, Vector2(3.0, 4.0), 3)
	assert_bool(shot.is_valid()).is_true()
	assert_float(shot.initial_speed(PhysicsConfig.default_config())).is_equal(660.0)
	var decoded := ShotInput.from_dict(shot.to_dict())
	assert_dict(decoded.to_dict()).is_equal(shot.to_dict())


func test_simulation_result_is_serializable() -> void:
	var result := SimulationResult.new()
	result.status = "success"
	result.ticks = 12
	result.stop_reason = "all_stopped"
	result.events.append(PhysicsEvent.ball_collision(3, 1, 2, Vector2(5.0, 6.0)))
	assert_dict(result.to_dict()).contains_keys(["status", "ticks", "stop_reason", "events", "final_snapshot", "state_hash"])
