class_name TechnicalTableTest
extends GdUnitTestSuite


func test_scene_has_seeded_rule_state_and_preview() -> void:
	var scene := load("res://scenes/technical_table.tscn") as PackedScene
	var table := scene.instantiate() as TechnicalTable
	add_child(table)
	await get_tree().process_frame
	assert_int(table.snapshot.balls.size()).is_equal(7)
	assert_int(table.snapshot.walls.size()).is_equal(2)
	assert_bool(table.preview.ok).is_true()
	table.queue_free()


func test_controls_change_power_assist_shoot_and_reset() -> void:
	var scene := load("res://scenes/technical_table.tscn") as PackedScene
	var table := scene.instantiate() as TechnicalTable
	add_child(table)
	await get_tree().process_frame
	table.power_level = 5
	table.assistance_index = 2
	table.shoot()
	assert_bool(table.playing).is_true()
	assert_int(table.playback_result.trajectories.size()).is_equal(7)
	table.reset_same_seed()
	assert_bool(table.playing).is_false()
	assert_int(table.power_level).is_equal(5)
	assert_int(table.assistance_index).is_equal(2)
	assert_int(table.snapshot.seed).is_equal(20260817)
	table.queue_free()
