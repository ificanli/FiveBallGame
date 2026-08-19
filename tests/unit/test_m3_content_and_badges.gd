class_name M3ContentAndBadgesTest
extends GdUnitTestSuite

func test_catalogs_are_complete_and_decision_focused() -> void:
	var badge_audit := BadgeCatalog.audit()
	var tool_audit := ToolCatalog.audit()
	assert_bool(badge_audit.ok).is_true()
	assert_int(badge_audit.decision_count).is_greater_equal(13)
	assert_bool(tool_audit.ok).is_true()
	assert_int(BadgeCatalog.BADGES.size()).is_equal(18)
	assert_int(ToolCatalog.TOOLS.size()).is_equal(6)

func test_localization_covers_existing_player_flow() -> void:
	var keys: Array[String] = ["game.title", "action.settle", "action.keep", "feedback.bust", "combo.same_color_straight", "phase.post_shot_decision"]
	var audit := LocalizationZhCn.audit(keys)
	assert_bool(audit.ok).is_true()
	assert_str(LocalizationZhCn.combo_name("pair")).is_equal("对子")

func test_badges_apply_in_left_to_right_order() -> void:
	var combo := ComboEvaluator.evaluate(_slots([[3,"red"],[4,"red"],[5,"red"]]))
	var context := SettlementContext.from_values(combo, {"hand_size":3})
	var result := BadgeSettlementPipeline.evaluate(context, ["pure_color_lamp", "perfect_hand"])
	assert_int(result.base_score).is_equal(144)
	assert_int(result.multiplier_add).is_equal(3)
	assert_int(result.multiplier_percent).is_equal(150)
	assert_int(result.final_score).is_equal(270)
	assert_array(result.steps.map(func(step): return step.badge_id)).contains_exactly(["pure_color_lamp", "perfect_hand"])

func test_three_builds_read_different_route_evidence() -> void:
	var combo := ComboEvaluator.evaluate(_slots([[3,"red"],[4,"red"],[5,"red"]]))
	var context := SettlementContext.from_values(combo, {"hand_size":3,"power_level":5,"rail_hits":2,"copy_count":1,"dyed_participant_count":1,"wall_kinds":["copy","dye"]})
	var pure := BadgeSettlementPipeline.evaluate(context, ["pure_color_lamp"])
	var rail := BadgeSettlementPipeline.evaluate(context, ["rail_guest", "fifth_gear"])
	var wall := BadgeSettlementPipeline.evaluate(context, ["copy_tax", "palette", "wall_circuit"])
	assert_int(pure.final_score).is_not_equal(rail.final_score)
	assert_int(rail.final_score).is_not_equal(wall.final_score)
	assert_bool(rail.steps[0].triggered).is_true()
	assert_bool(wall.steps[2].triggered).is_true()

func test_growth_is_previewed_as_change_without_mutating_input() -> void:
	var combo := ComboEvaluator.evaluate(_slots([[3,"red"],[4,"red"],[5,"red"]]))
	var growth := {"color_straight_prize":2}
	var result := BadgeSettlementPipeline.evaluate(SettlementContext.from_values(combo,{"hand_size":3}), ["color_straight_prize"], growth)
	assert_int(result.multiplier_add).is_equal(2)
	assert_int(result.growth_changes.color_straight_prize).is_equal(3)
	assert_int(growth.color_straight_prize).is_equal(2)

func _slots(values: Array) -> Array[HandSlot]:
	var output: Array[HandSlot] = []
	for index in values.size():
		output.append(HandSlot.physical(BallState.new(index+2,"number",values[index][0],values[index][1])))
	return output
