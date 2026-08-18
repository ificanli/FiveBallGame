class_name CoreLoopSessionRunnerTest
extends GdUnitTestSuite

func test_identical_session_repeats_with_same_hash() -> void:
	var state := CoreLoopSnapshot.create_tutorial()
	state.table.balls = [state.table.find_ball(1), state.table.find_ball(2)]
	state.collection_states = {2: "uncollected"}
	state.target_score = 3
	state.strokes_remaining = 1
	var commands: Array[Dictionary] = [{"type": "shoot", "direction": {"x": 1, "y": 0}, "power": 3}, {"type": "settle"}]
	var first := CoreLoopSessionRunner.new().run(state, commands)
	for iteration in 100:
		var repeated := CoreLoopSessionRunner.new().run(state, commands)
		assert_str(repeated.state_hash).override_failure_message("drift at %d" % iteration).is_equal(first.state_hash)
	assert_str(first.rules_version).is_equal(CoreLoopSnapshot.RULES_VERSION)
	assert_int(first.steps.size()).is_equal(2)

func test_copy_uses_impact_time_color_before_later_dye() -> void:
	var state := CoreLoopSnapshot.create_tutorial()
	var result := SimulationResult.new()
	result.final_snapshot = state.table.duplicate_state()
	result.final_snapshot.find_ball(2).color_id = "blue"
	result.events.assign([
		PhysicsEvent.rule_event("activation", 1, 2, 0, {"source_id": 1}),
		PhysicsEvent.rule_event("copy", 2, 2, 1, {"number": 3, "color_id": "red"}),
		PhysicsEvent.rule_event("dye", 3, 2, 2, {"old_color_id": "red", "new_color_id": "blue"}),
	])
	CoreLoopReducer.new().apply_simulation(state, result)
	assert_str(state.hand[0].color_id).is_equal("blue")
	assert_str(state.hand[1].color_id).is_equal("red")
