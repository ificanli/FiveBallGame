class_name TechnicalTableTest
extends GdUnitTestSuite

func test_scene_has_seeded_rule_state_and_preview() -> void:
	var table := (load("res://scenes/technical_table.tscn") as PackedScene).instantiate() as TechnicalTable
	add_child(table)
	await get_tree().process_frame
	assert_str(table.run_controller.state.phase).is_equal("reward")
	table.choose_reward(0)
	assert_int(table.snapshot.balls.size()).is_equal(7)
	assert_int(table.snapshot.walls.size()).is_equal(2)
	assert_int(table.controller.state.target_score).is_equal(220)
	assert_int(table.controller.state.strokes_remaining).is_equal(5)
	assert_array(table.legal_actions()).contains_exactly(["shoot", "reset"])
	assert_bool(table.preview.ok).is_true()
	table.queue_free()

func test_controls_change_power_assist_shoot_and_reset() -> void:
	var table := (load("res://scenes/technical_table.tscn") as PackedScene).instantiate() as TechnicalTable
	add_child(table)
	await get_tree().process_frame
	table.choose_reward(0)
	table.power_level = 5
	table.assistance_index = 2
	table.shoot()
	assert_bool(table.playing).is_true()
	assert_int(table.playback_result.trajectories.size()).is_equal(7)
	table.reset_same_seed()
	assert_bool(table.playing).is_false()
	assert_str(table.run_controller.state.phase).is_equal("reward")
	assert_int(table.run_controller.state.seed).is_equal(20260819)
	table.queue_free()

func test_view_model_cannot_mutate_rule_truth() -> void:
	var table := (load("res://scenes/technical_table.tscn") as PackedScene).instantiate() as TechnicalTable
	add_child(table)
	await get_tree().process_frame
	table.choose_reward(0)
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


func test_drag_mapping_derives_direction_and_power() -> void:
	var table := (load("res://scenes/technical_table.tscn") as PackedScene).instantiate() as TechnicalTable
	add_child(table)
	await get_tree().process_frame
	table.choose_reward(0)
	var cue := table.snapshot.find_ball(1)
	var anchor: Vector2 = TechnicalTable.TABLE_RECT.position + cue.position
	# 拖到母球左侧 150px → 弹弓式: 向左拉, 向右发射; 档位 3 (150/260*5=2.88→3)
	table._update_drag(anchor + Vector2(-150, 0))
	assert_vector(table.aim_direction).is_equal_approx(Vector2.RIGHT, Vector2(0.0001, 0.0001))
	assert_int(table.power_level).is_equal(3)
	# 拖到左上 260px → 向左上拉, 向右下发射, 满档 5
	table._update_drag(anchor + Vector2(-260, -260))
	assert_vector(table.aim_direction).is_equal_approx(Vector2.ONE.normalized(), Vector2(0.0001, 0.0001))
	assert_int(table.power_level).is_equal(5)
	# 拖拽从未超过最大距离
	table._update_drag(anchor + Vector2(-9999, 0))
	assert_int(table.power_level).is_equal(5)
	table.queue_free()


func test_input_mode_toggle_persists_and_syncs_hud() -> void:
	var table := (load("res://scenes/technical_table.tscn") as PackedScene).instantiate() as TechnicalTable
	add_child(table)
	await get_tree().process_frame
	table.choose_reward(0)
	var before: String = GameSession.input_mode
	table._toggle_input_mode()
	assert_str(GameSession.input_mode).is_equal("fine" if before == "drag" else "drag")
	assert_str(table.input_mode).is_equal(GameSession.input_mode)
	table._toggle_input_mode()
	assert_str(GameSession.input_mode).is_equal(before)
	table.queue_free()


func test_fine_mode_click_aims_without_shooting() -> void:
	var table := (load("res://scenes/technical_table.tscn") as PackedScene).instantiate() as TechnicalTable
	add_child(table)
	await get_tree().process_frame
	table.choose_reward(0)
	table.input_mode = "fine"
	table.aim_direction = Vector2.RIGHT
	var cue := table.snapshot.find_ball(1)
	var target_screen: Vector2 = TechnicalTable.TABLE_RECT.position + cue.position + Vector2(0, -80)
	table._aim_at(target_screen)
	assert_bool(table.playing).is_false()
	assert_vector(table.aim_direction).is_equal_approx(Vector2.UP, Vector2(0.0001, 0.0001))
	table.queue_free()
