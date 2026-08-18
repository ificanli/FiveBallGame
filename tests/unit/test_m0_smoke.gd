class_name M0SmokeTest
extends GdUnitTestSuite


func test_project_identity() -> void:
	assert_str(ProjectSettings.get_setting("application/config/name", "")).is_equal("Five Ball Grand Slam")


func test_versioned_golden_case_contract_loads() -> void:
	var loaded: Dictionary = ReplayCodec.load_case("res://tests/golden_replay/cases/versioned_schema_smoke.json")
	assert_bool(loaded.ok).is_true()
	assert_dict(loaded.case).contains_keys([
		"schema_version", "case_id", "physics_version", "content_version",
		"seed", "initial_snapshot", "shot_input", "expected"
	])
	assert_str(loaded.case.case_id).is_equal("versioned-schema-smoke")
