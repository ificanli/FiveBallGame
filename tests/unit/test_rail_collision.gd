class_name RailCollisionTest
extends GdUnitTestSuite


func test_perpendicular_rail_impact_reverses_normal_velocity() -> void:
	var snapshot := _single_ball(Vector2(25.0, 300.0), Vector2(-300.0, 40.0))
	var simulator := PhysicsSimulator.new()
	var config := PhysicsConfig.default_config()
	for tick in 8:
		simulator.step_tick(snapshot, config, tick, [])
		if snapshot.balls[0].velocity.x > 0.0:
			break
	assert_float(snapshot.balls[0].velocity.x).is_greater(0.0)
	assert_float(snapshot.balls[0].velocity.y).is_greater(0.0)
	assert_float(snapshot.balls[0].position.x).is_greater_equal(18.0)


func test_corner_approach_stays_inside_both_rails() -> void:
	var snapshot := _single_ball(Vector2(20.0, 20.0), Vector2(-600.0, -500.0))
	var events: Array[PhysicsEvent] = []
	PhysicsSimulator.new().step_tick(snapshot, PhysicsConfig.default_config(), 0, events)
	assert_float(snapshot.balls[0].position.x).is_greater_equal(18.0)
	assert_float(snapshot.balls[0].position.y).is_greater_equal(18.0)
	assert_float(snapshot.balls[0].velocity.x).is_greater(0.0)
	assert_float(snapshot.balls[0].velocity.y).is_greater(0.0)
	assert_int(events.filter(func(event: PhysicsEvent) -> bool: return event.type == "rail_collision").size()).is_equal(2)


func test_rail_restitution_is_independent() -> void:
	var snapshot := _single_ball(Vector2(18.5, 300.0), Vector2(-100.0, 0.0))
	var config := PhysicsConfig.default_config()
	config.rail_restitution = 0.5
	config.drag_per_tick = 1.0
	PhysicsSimulator.new().step_tick(snapshot, config, 0, [])
	assert_float(snapshot.balls[0].velocity.x).is_equal_approx(50.0, 0.01)


func _single_ball(position: Vector2, velocity: Vector2) -> TableSnapshot:
	var snapshot := TableSnapshot.new()
	snapshot.balls.append(BallState.new(1, "cue", 0, "", position, velocity, 18.0))
	return snapshot
