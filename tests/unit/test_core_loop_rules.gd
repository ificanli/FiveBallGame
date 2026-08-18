class_name CoreLoopRulesTest
extends GdUnitTestSuite


func test_snapshot_round_trip_and_validation() -> void:
	var state := _state()
	var ball := state.table.find_ball(2)
	state.collection_states[2] = "hand"
	state.hand.append(HandSlot.physical(ball))
	state.refresh_combo()
	var restored := CoreLoopSnapshot.from_dict(state.to_dict())
	assert_dict(restored.validate()).contains_key_value("ok", true)
	assert_str(restored.state_hash()).is_equal(state.state_hash())
	assert_int(restored.hand[0].physical_ball_id).is_equal(2)


func test_duplicate_physical_ownership_is_rejected() -> void:
	var state := _state()
	var ball := state.table.find_ball(2)
	state.collection_states[2] = "hand"
	state.hand.assign([HandSlot.physical(ball), HandSlot.physical(ball)])
	assert_str(state.validate().code).is_equal("duplicate_physical_slot")


func test_activation_collects_once_and_dye_syncs_slot() -> void:
	var state := _state()
	var result := SimulationResult.new()
	result.final_snapshot = state.table.duplicate_state()
	result.final_snapshot.find_ball(2).color_id = "red"
	result.events.assign([
		PhysicsEvent.rule_event("activation", 2, 2, 0, {"source_id": 1}),
		PhysicsEvent.rule_event("activation", 4, 2, 0, {"source_id": 1}),
		PhysicsEvent.rule_event("dye", 8, 2, 1, {"new_color_id": "red"}),
	])
	var events := CoreLoopReducer.new().apply_simulation(state, result)
	assert_int(state.hand.size()).is_equal(1)
	assert_str(state.collection_state(2)).is_equal("hand")
	assert_str(state.hand[0].color_id).is_equal("red")
	assert_array(events.map(func(event: Dictionary) -> String: return event.type)).contains_exactly(["collected", "slot_dyed"])


func test_copy_creates_slot_without_physical_id() -> void:
	var state := _state()
	var result := SimulationResult.new()
	result.final_snapshot = state.table.duplicate_state()
	result.events.assign([
		PhysicsEvent.rule_event("activation", 2, 2, 0, {"source_id": 1}),
		PhysicsEvent.rule_event("copy", 5, 2, 1, {"number": 1, "color_id": "blue"}),
	])
	CoreLoopReducer.new().apply_simulation(state, result)
	assert_int(state.hand.size()).is_equal(2)
	assert_bool(state.hand[1].has_physical_ball).is_false()
	assert_str(state.combo.type).is_equal("pair")


func test_sixth_physical_collection_busts_and_locks_later_effects() -> void:
	var state := _state_with_numbers(6)
	for id in range(2, 7):
		state.collection_states[id] = "hand"
		state.hand.append(HandSlot.physical(state.table.find_ball(id)))
	var result := SimulationResult.new()
	result.final_snapshot = state.table.duplicate_state()
	result.events.assign([
		PhysicsEvent.rule_event("activation", 10, 7, 0, {"source_id": 2}),
		PhysicsEvent.rule_event("dye", 11, 2, 1, {"new_color_id": "red"}),
	])
	var events := CoreLoopReducer.new().apply_simulation(state, result)
	assert_bool(state.shot_busted).is_true()
	assert_int(state.hand.size()).is_zero()
	for id in range(2, 8):
		assert_str(state.collection_state(id)).is_equal("waste")
	assert_array(events.map(func(event: Dictionary) -> String: return event.type)).contains_exactly(["bust", "ignored_after_bust"])


func test_settled_waste_ball_cannot_be_recollected() -> void:
	var state := _state()
	state.collection_states[2] = "waste"
	var result := SimulationResult.new()
	result.final_snapshot = state.table.duplicate_state()
	result.events.assign([PhysicsEvent.rule_event("activation", 2, 2, 0, {"source_id": 1})])
	CoreLoopReducer.new().apply_simulation(state, result)
	assert_int(state.hand.size()).is_zero()
	assert_str(state.collection_state(2)).is_equal("waste")


func _state() -> CoreLoopSnapshot:
	return _state_with_numbers(2)


func _state_with_numbers(count: int) -> CoreLoopSnapshot:
	var table := TableSnapshot.new()
	table.balls.append(BallState.new(1, "cue", 0, "", Vector2(100, 100)))
	var colors := ["blue", "red", "green", "yellow"]
	for index in count:
		table.balls.append(BallState.new(index + 2, "number", index % 9 + 1, colors[index % colors.size()], Vector2(200 + index * 50, 100)))
	return CoreLoopSnapshot.create(table, 100, 6)
