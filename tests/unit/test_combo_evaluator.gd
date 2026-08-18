class_name ComboEvaluatorTest
extends GdUnitTestSuite


func test_catalog_multipliers() -> void:
	var cases := [
		{"slots": [[5, "red"]], "type": "single", "multiplier": 1},
		{"slots": [[4, "red"], [4, "blue"]], "type": "pair", "multiplier": 3},
		{"slots": [[4, "red"], [4, "blue"], [4, "green"]], "type": "three_of_a_kind", "multiplier": 7},
		{"slots": [[4, "red"], [4, "blue"], [4, "green"], [4, "yellow"]], "type": "bomb", "multiplier": 15},
		{"slots": [[4, "red"], [4, "blue"], [4, "green"], [4, "yellow"], [4, "red"]], "type": "five_ball_grand_slam", "multiplier": 30},
		{"slots": [[3, "red"], [4, "blue"], [5, "yellow"]], "type": "straight", "multiplier": 5},
		{"slots": [[2, "red"], [5, "red"], [8, "red"], [9, "red"]], "type": "same_color", "multiplier": 7},
		{"slots": [[3, "red"], [4, "red"], [5, "red"]], "type": "same_color_straight", "multiplier": 12},
	]
	for item: Dictionary in cases:
		var result := ComboEvaluator.evaluate(_slots(item.slots))
		assert_str(result.type).is_equal(item.type)
		assert_int(result.multiplier).is_equal(item.multiplier)


func test_pollution_does_not_score() -> void:
	var result := ComboEvaluator.evaluate(_slots([[3, "red"], [4, "red"], [5, "red"], [9, "blue"]]))
	assert_str(result.type).is_equal("same_color_straight")
	assert_int(result.score).is_equal(144)
	assert_array(result.participant_indices).contains_exactly([0, 1, 2])
	assert_array(result.pollution_indices).contains_exactly([3])


func test_copy_slot_participates_without_physical_id() -> void:
	var ball := BallState.new(2, "number", 7, "yellow")
	var slots: Array[HandSlot] = [HandSlot.physical(ball), HandSlot.copy_of(ball, 3)]
	var result := ComboEvaluator.evaluate(slots)
	assert_str(result.type).is_equal("pair")
	assert_int(result.score).is_equal(42)
	assert_bool(slots[1].has_physical_ball).is_false()


func test_empty_hand_has_zero_score() -> void:
	var result := ComboEvaluator.evaluate([])
	assert_str(result.type).is_equal("none")
	assert_int(result.score).is_zero()


func _slots(values: Array) -> Array[HandSlot]:
	var output: Array[HandSlot] = []
	for index in values.size():
		var value: Array = values[index]
		output.append(HandSlot.physical(BallState.new(index + 2, "number", value[0], value[1])))
	return output
