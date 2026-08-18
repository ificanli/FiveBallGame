class_name TechnicalTableTest
extends GdUnitTestSuite

func test_scene_has_seeded_rule_state_and_preview() -> void:
	var table := (load("res://scenes/technical_table.tscn") as PackedScene).instantiate() as TechnicalTable
	add_child(table)
	await get_tree().process_frame
	assert_int(table.snapshot.balls.size()).is_equal(7)
	assert_int(table.snapshot.walls.size()).is_equal(2)
	assert_int(table.controller.state.target_score).is_equal(180)
	assert_int(table.controller.state.strokes_remaining).is_equal(8)
	assert_array(table.legal_actions()).contains_exactly(["shoot", "reset"])
	assert_bool(table.preview.ok).is_true()
	table.queue_free()

func test_controls_change_power_assist_shoot_and_reset() -> void:
	var table := (load("res://scenes/technical_table.tscn") as PackedScene).instantiate() as TechnicalTable
	add_child(table)
	await get_tree().process_frame
	table.power_level = 5
	table.assistance_index = 2
	table.shoot()
	assert_bool(table.playing).is_true()
	assert_int(table.playback_result.trajectories.size()).is_equal(7)
	table.reset_same_seed()
	assert_bool(table.playing).is_false()
	assert_int(table.snapshot.seed).is_equal(20260818)
	table.queue_free()

func test_view_model_cannot_mutate_rule_truth() -> void:
	var table := (load("res://scenes/technical_table.tscn") as PackedScene).instantiate() as TechnicalTable
	add_child(table)
	await get_tree().process_frame
	var ball := table.snapshot.find_ball(2)
	table.controller.state.collection_states[2] = "hand"
	table.controller.state.hand.append(HandSlot.physical(ball))
	table.controller.state.refresh_combo()
	table.controller.state.phase = "post_shot_decision"
	var model := table.view_model()
	model.combo["score"] = 9999
	assert_int(table.controller.state.combo.score).is_equal(3)
	assert_array(table.legal_actions()).contains_exactly(["settle", "keep", "reset"])
	table.queue_free()
