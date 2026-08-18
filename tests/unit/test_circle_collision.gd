class_name CircleCollisionTest
extends GdUnitTestSuite


func test_direct_equal_mass_collision_transfers_motion() -> void:
	var snapshot := _two_balls(Vector2(300.0, 310.0), Vector2(350.0, 310.0))
	snapshot.balls[0].velocity = Vector2(600.0, 0.0)
	var events: Array[PhysicsEvent] = []
	var simulator := PhysicsSimulator.new()
	for tick in 20:
		simulator.step_tick(snapshot, PhysicsConfig.default_config(), tick, events)
	assert_float(snapshot.balls[1].velocity.x).is_greater(snapshot.balls[0].velocity.x)
	assert_bool(events.any(func(event: PhysicsEvent) -> bool: return event.type == "ball_collision")).is_true()
	assert_float(snapshot.balls[0].position.distance_to(snapshot.balls[1].position)).is_greater_equal(35.99)


func test_glancing_collision_creates_normal_and_tangent_motion() -> void:
	var snapshot := _two_balls(Vector2(300.0, 300.0), Vector2(350.0, 320.0))
	snapshot.balls[0].velocity = Vector2(700.0, 0.0)
	var simulator := PhysicsSimulator.new()
	for tick in 20:
		simulator.step_tick(snapshot, PhysicsConfig.default_config(), tick, [])
	assert_float(absf(snapshot.balls[1].velocity.y)).is_greater(1.0)
	assert_float(snapshot.balls[0].velocity.x).is_greater(0.0)


func test_small_initial_overlap_is_corrected_without_energy() -> void:
	var snapshot := _two_balls(Vector2(300.0, 300.0), Vector2(335.0, 300.0))
	var simulator := PhysicsSimulator.new()
	simulator.step_tick(snapshot, PhysicsConfig.default_config(), 0, [])
	assert_float(snapshot.balls[0].position.distance_to(snapshot.balls[1].position)).is_greater_equal(35.99)
	assert_vector(snapshot.balls[0].velocity).is_equal(Vector2.ZERO)
	assert_vector(snapshot.balls[1].velocity).is_equal(Vector2.ZERO)


func test_dense_contacts_remain_finite() -> void:
	var snapshot := TableSnapshot.new()
	for index in 7:
		snapshot.balls.append(BallState.new(index + 1, "cue" if index == 0 else "number", index, "red", Vector2(280.0 + index * 36.0, 310.0)))
	snapshot.balls[0].velocity = Vector2(1100.0, 0.0)
	var result := PhysicsSimulator.new().simulate_existing_motion(snapshot)
	assert_str(result.status).is_equal("success")
	for ball: BallState in result.final_snapshot.balls:
		assert_bool(ball.position.is_finite()).is_true()
		assert_bool(ball.velocity.is_finite()).is_true()


func test_maximum_power_does_not_tunnel_through_target() -> void:
	var snapshot := _two_balls(Vector2(150.0, 310.0), Vector2(245.0, 310.0))
	var result := PhysicsSimulator.new().simulate(snapshot, ShotInput.create(1, Vector2.RIGHT, 5))
	assert_bool(result.events.any(func(event: PhysicsEvent) -> bool: return event.type == "ball_collision" and event.primary_id == 1 and event.secondary_id == 2)).is_true()
	assert_float(result.final_snapshot.balls[1].position.x).is_greater(245.0)


func _two_balls(first: Vector2, second: Vector2) -> TableSnapshot:
	var snapshot := TableSnapshot.new()
	snapshot.balls.append(BallState.new(1, "cue", 0, "", first))
	snapshot.balls.append(BallState.new(2, "number", 3, "red", second))
	return snapshot
