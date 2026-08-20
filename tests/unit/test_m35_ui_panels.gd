class_name M35UiPanelsTest
extends GdUnitTestSuite


func test_technical_table_builds_node_panels() -> void:
	var table := (load("res://scenes/technical_table.tscn") as PackedScene).instantiate() as TechnicalTable
	add_child(table)
	await get_tree().process_frame
	assert_bool(table.hud is HudPanel).is_true()
	assert_bool(table.reward_panel is RewardPanel).is_true()
	assert_bool(table.tool_selector is ToolSelector).is_true()
	assert_bool(table.badge_panel is BadgePanel).is_true()
	assert_bool(table.run_summary is RunSummaryPanel).is_true()
	assert_bool(table.pause_menu is PauseMenu).is_true()
	assert_bool(table.tutorial is TutorialOverlay).is_true()
	table.queue_free()


func test_localization_has_no_forbidden_prototype_labels() -> void:
	for key: String in LocalizationZhCn.TEXT:
		var value: String = LocalizationZhCn.TEXT[key]
		for forbidden: String in LocalizationZhCn.FORBIDDEN_PROTOTYPE_LABELS:
			assert_bool(value.contains(forbidden)).is_false()


func test_view_model_exposes_chinese_assist_and_badges() -> void:
	var table := (load("res://scenes/technical_table.tscn") as PackedScene).instantiate() as TechnicalTable
	add_child(table)
	await get_tree().process_frame
	var model := table.view_model()
	assert_bool(str(model.get("assist", "")).is_empty()).is_false()
	table.choose_reward(0)
	var model2 := table.view_model()
	assert_bool(model2.has("badges")).is_true()
	assert_bool(model2.has("tools")).is_true()
	assert_int(model2.badges.size()).is_equal(1)
	table.queue_free()
