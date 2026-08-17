class_name M0SmokeTest
extends GdUnitTestSuite


func test_project_identity() -> void:
	assert_str(ProjectSettings.get_setting("application/config/name", "")).is_equal("Five Ball Grand Slam")


func test_golden_case_contract_loads() -> void:
	var file := FileAccess.open("res://tests/golden_replay/cases/m0_contract_smoke.json", FileAccess.READ)
	assert_object(file).is_not_null()
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	assert_dict(parsed).contains_keys(["schema_version", "case_id", "input", "expected"])
	assert_str(parsed["case_id"]).is_equal("m0-contract-smoke")
