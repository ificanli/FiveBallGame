class_name ReplayRunnerTest
extends GdUnitTestSuite


func test_valid_case_outputs_structured_result() -> void:
	var loaded := ReplayCodec.load_case("res://tests/golden_replay/cases/direct-hit.json")
	assert_bool(loaded.ok).is_true()
	var actual := ReplayRunner.new().execute_case(loaded.case)
	assert_dict(actual).contains_keys([
		"case_id", "status", "events", "final_ball_states", "wall_states",
		"ticks", "stop_reason", "state_hash", "error"
	])
	assert_str(actual.status).is_equal("success")
	assert_str(actual.state_hash).is_not_empty()


func test_invalid_case_returns_structured_validation_error() -> void:
	var actual := ReplayRunner.new().execute_case({"case_id": "broken"})
	assert_str(actual.status).is_equal("validation_error")
	assert_array(actual.errors).contains(["missing:physics_version"])


func test_missing_expected_fails_without_writing() -> void:
	var loaded := ReplayCodec.load_case("res://tests/golden_replay/cases/direct-hit.json")
	loaded.case.expected = {}
	var comparison := ReplayRunner.new().compare_case(loaded.case)
	assert_bool(comparison.passed).is_false()
	assert_str(comparison.difference.path).is_equal("$.expected")


func test_first_event_difference_is_reported() -> void:
	var loaded := ReplayCodec.load_case("res://tests/golden_replay/cases/direct-hit.json")
	var runner := ReplayRunner.new()
	var actual := runner.execute_case(loaded.case)
	loaded.case.expected = runner.comparable_output(actual)
	loaded.case.expected.events = [{"type": "wrong"}]
	var comparison := runner.compare_case(loaded.case)
	assert_bool(comparison.passed).is_false()
	assert_bool(str(comparison.difference.path).begins_with("$.events")).is_true()
