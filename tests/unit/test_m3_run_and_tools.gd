class_name M3RunAndToolsTest
extends GdUnitTestSuite

func test_run_round_trip_and_rewards_are_stable() -> void:
	var run:=RunSnapshot.create(12345)
	assert_array(run.reward_choices).contains_exactly(["twin_ring","rail_guest","copy_tax"])
	var copy:=RunSnapshot.from_dict(run.to_dict())
	assert_str(copy.state_hash()).is_equal(run.state_hash())
	assert_bool(copy.validate().ok).is_true()

func test_reward_starts_table_and_three_rewards_build_three_badges() -> void:
	var controller:=RunController.new(RunSnapshot.create(7))
	assert_bool(controller.choose_reward("twin_ring").ok).is_true()
	assert_int(controller.state.table_index).is_equal(0)
	assert_str(controller.state.phase).is_equal("playing")
	controller.state.current_table.phase="won"; controller._complete_table(10)
	var choice:String=controller.state.reward_choices[0]
	assert_bool(controller.choose_reward(choice).ok).is_true()
	controller.state.current_table.phase="won"; controller._complete_table(10)
	choice=controller.state.reward_choices[0]
	assert_bool(controller.choose_reward(choice).ok).is_true()
	assert_int(controller.state.badges.size()).is_equal(3)
	assert_int(controller.state.table_index).is_equal(2)

func test_reward_reopen_does_not_refresh() -> void:
	var run:=RunSnapshot.create(99)
	var first: Array = run.reward_choices.duplicate()
	var regenerated: Array = RunContent.reward_choices(99,0,[])
	assert_array(regenerated).contains_exactly(first)

func test_replenishment_is_deterministic_and_non_overlapping() -> void:
	var left:=CoreLoopSnapshot.create(TableSnapshot.new(),100,5)
	left.table.balls.append(BallState.new(1,"cue",0,"",Vector2(130,315)))
	var right:=left.duplicate_state()
	var a:=ReplenishmentService.replenish(left,6,44,0)
	var b:=ReplenishmentService.replenish(right,6,44,0)
	assert_bool(a.ok).is_true(); assert_bool(b.ok).is_true()
	assert_str(left.state_hash()).is_equal(right.state_hash())
	assert_int(a.spawned.size()).is_equal(6)
	for i in left.table.balls.size():
		for j in range(i+1,left.table.balls.size()): assert_float(left.table.balls[i].position.distance_to(left.table.balls[j].position)).is_greater(35.9)

func test_editing_tools_are_atomic_and_sync_slots() -> void:
	var run:=_run_with_hand()
	run.tools={"color_chalk":1,"number_sticker":1,"return_hook":1}
	var dye:=ToolService.use(run,"color_chalk",{"ball_id":2,"color_id":"blue"})
	assert_bool(dye.ok).is_true(); assert_str(run.current_table.find_physical_slot(2).color_id).is_equal("blue")
	var invalid:=ToolService.use(run,"number_sticker",{"ball_id":2,"delta":2})
	assert_bool(invalid.ok).is_false(); assert_int(run.tools.number_sticker).is_equal(1)
	var hook:=ToolService.use(run,"return_hook",{"ball_id":2})
	assert_bool(hook.ok).is_true(); assert_int(run.current_table.hand.size()).is_zero(); assert_str(run.current_table.collection_state(2)).is_equal("waste")

func test_table_reset_preserves_score_and_strokes() -> void:
	var run:=_run_with_hand(); run.tools={"table_reset":1}; run.current_table.score=77; run.current_table.strokes_remaining=3; run.current_table.phase="post_shot_decision"
	var result:=ToolService.use(run,"table_reset")
	assert_bool(result.ok).is_true(); assert_int(run.current_table.score).is_equal(77); assert_int(run.current_table.strokes_remaining).is_equal(3); assert_int(run.current_table.hand.size()).is_zero()

func test_badge_reorder_is_stable() -> void:
	var run:=RunSnapshot.create(1); run.badges.assign(["twin_ring","straight_compass","pure_color_lamp"])
	var controller:=RunController.new(run)
	assert_bool(controller.reorder_badges(2,0).ok).is_true()
	assert_array(run.badges).contains_exactly(["pure_color_lamp","twin_ring","straight_compass"])

func _run_with_hand()->RunSnapshot:
	var run:=RunSnapshot.create(1); run.phase="playing"; run.table_index=0; run.current_table=RunContent.create_table(1,0)
	var ball:=run.current_table.table.find_ball(2); run.current_table.collection_states[2]="hand"; run.current_table.hand.append(HandSlot.physical(ball)); run.current_table.refresh_combo(); run.current_table.phase="post_shot_decision"
	return run
