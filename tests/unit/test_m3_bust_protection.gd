class_name M3BustProtectionTest
extends GdUnitTestSuite

func test_soft_pocket_discards_physical_sixth_and_keeps_five() -> void:
	var state:=_five_hand_state()
	state.active_bust_protection="soft_pocket"
	var event:=PhysicsEvent.rule_event("activation",1,7)
	var result:=_result(state,[event])
	var events:=CoreLoopReducer.new().apply_simulation(state,result)
	assert_bool(state.shot_busted).is_false()
	assert_int(state.hand.size()).is_equal(5)
	assert_str(state.collection_state(7)).is_equal("waste")
	assert_str(events[0].type).is_equal("soft_pocket_saved")

func test_insurance_accepts_sixth_and_forces_settlement() -> void:
	var state:=_five_hand_state()
	state.active_bust_protection="insurance_slot"; state.hand_capacity=6
	var event:=PhysicsEvent.rule_event("activation",1,7)
	var result:=_result(state,[event])
	var events:=CoreLoopReducer.new().apply_simulation(state,result)
	assert_bool(state.shot_busted).is_false()
	assert_int(state.hand.size()).is_equal(6)
	assert_bool(state.forced_settle).is_true()
	assert_str(events[0].type).is_equal("insurance_slot_used")
	state.phase="post_shot_decision"
	var controller:=CoreLoopController.new(state)
	assert_array(controller.allowed_actions()).contains_exactly(["settle","reset"])
	assert_bool(controller.keep().ok).is_false()

func test_default_sixth_still_busts() -> void:
	var state:=_five_hand_state()
	var result:=_result(state,[PhysicsEvent.rule_event("activation",1,7)])
	CoreLoopReducer.new().apply_simulation(state,result)
	assert_bool(state.shot_busted).is_true()
	assert_int(state.hand.size()).is_zero()

func _result(state:CoreLoopSnapshot,events:Array)->SimulationResult:
	var result:=SimulationResult.new(); result.status="success"; result.ticks=1; result.final_snapshot=state.table.duplicate_state(); result.events.assign(events); return result

func _five_hand_state()->CoreLoopSnapshot:
	var state:=CoreLoopSnapshot.create_tutorial()
	for id in range(2,7):
		state.collection_states[id]="hand"; state.hand.append(HandSlot.physical(state.table.find_ball(id)))
	state.refresh_combo()
	return state
