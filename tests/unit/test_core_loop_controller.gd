class_name CoreLoopControllerTest
extends GdUnitTestSuite


func test_valid_shot_consumes_once_and_movement_state_locks_input() -> void:
	var controller := CoreLoopController.new(_state(2, 100))
	controller.state.phase = "simulating"
	assert_str(controller.shoot(ShotInput.create(1, Vector2.RIGHT, 1)).code).is_equal("shoot_not_allowed")
	assert_int(controller.state.strokes_remaining).is_equal(2)
	controller.state.phase = "aiming"
	var result := controller.shoot(ShotInput.create(1, Vector2.RIGHT, 1))
	assert_bool(result.ok).is_true()
	assert_int(controller.state.strokes_remaining).is_equal(1)


func test_settle_banks_score_and_turns_physical_hand_to_waste() -> void:
	var state := _state(2, 5)
	_add_hand_ball(state, 2)
	state.phase = "post_shot_decision"
	var controller := CoreLoopController.new(state)
	var result := controller.settle()
	assert_bool(result.ok).is_true()
	assert_int(state.score).is_equal(3)
	assert_int(state.hand.size()).is_zero()
	assert_str(state.collection_state(2)).is_equal("waste")
	assert_str(state.phase).is_equal("aiming")


func test_settle_reaching_target_wins_and_locks_shoot() -> void:
	var state := _state(2, 3)
	_add_hand_ball(state, 2)
	state.phase = "post_shot_decision"
	var controller := CoreLoopController.new(state)
	controller.settle()
	assert_str(state.phase).is_equal("won")
	assert_str(controller.shoot(ShotInput.create(1, Vector2.RIGHT, 1)).code).is_equal("shoot_not_allowed")


func test_keep_preserves_hand_and_score() -> void:
	var state := _state(2, 100)
	_add_hand_ball(state, 2)
	state.phase = "post_shot_decision"
	state.score = 9
	var controller := CoreLoopController.new(state)
	assert_bool(controller.keep().ok).is_true()
	assert_str(state.phase).is_equal("aiming")
	assert_int(state.hand.size()).is_equal(1)
	assert_int(state.score).is_equal(9)


func test_final_hand_can_settle_but_cannot_keep() -> void:
	var state := _state(0, 100)
	_add_hand_ball(state, 2)
	state.phase = "post_shot_decision"
	var controller := CoreLoopController.new(state)
	assert_str(controller.keep().code).is_equal("no_strokes_remaining")
	assert_bool(controller.settle().ok).is_true()
	assert_str(state.phase).is_equal("lost")


func test_empty_final_shot_loses() -> void:
	var state := _state(1, 100)
	var controller := CoreLoopController.new(state)
	controller.shoot(ShotInput.create(1, Vector2.UP, 1))
	assert_str(state.phase).is_equal("lost")


func test_waste_ball_is_runtime_ineligible_for_activation() -> void:
	var state := _state(1, 100)
	state.collection_states[2] = "waste"
	var controller := CoreLoopController.new(state)
	controller.shoot(ShotInput.create(1, Vector2.RIGHT, 1))
	assert_bool(controller.last_simulation.final_snapshot.find_ball(2).active).is_false()
	assert_int(state.hand.size()).is_zero()


func _state(strokes: int, target: int) -> CoreLoopSnapshot:
	var table := TableSnapshot.new()
	table.balls.assign([
		BallState.new(1, "cue", 0, "", Vector2(100, 300)),
		BallState.new(2, "number", 3, "red", Vector2(500, 300)),
	])
	return CoreLoopSnapshot.create(table, target, strokes)


func _add_hand_ball(state: CoreLoopSnapshot, id: int) -> void:
	state.collection_states[id] = "hand"
	state.hand.append(HandSlot.physical(state.table.find_ball(id)))
	state.refresh_combo()
