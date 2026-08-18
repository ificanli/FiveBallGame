class_name ReplayContractTest
extends GdUnitTestSuite


func test_missing_required_replay_field_is_rejected() -> void:
	var result: Dictionary = ReplayCodec.validate_case({"schema_version": 1})
	assert_bool(result.valid).is_false()
	assert_array(result.errors).contains(["missing:physics_version"])


func test_unsupported_physics_version_is_rejected() -> void:
	var fixture := _valid_case()
	fixture.physics_version = "future"
	var result: Dictionary = ReplayCodec.validate_case(fixture)
	assert_bool(result.valid).is_false()
	assert_array(result.errors).contains(["unsupported:physics_version:future"])


func test_invalid_power_and_direction_are_rejected() -> void:
	var fixture := _valid_case()
	fixture.shot_input.power_level = 6
	fixture.shot_input.direction = {"x": 0.0, "y": 0.0}
	var result: Dictionary = ReplayCodec.validate_case(fixture)
	assert_bool(result.valid).is_false()
	assert_array(result.errors).contains(["invalid:power_level", "invalid:direction"])


func test_duplicate_ball_ids_are_rejected() -> void:
	var fixture := _valid_case()
	fixture.initial_snapshot.balls.append(fixture.initial_snapshot.balls[0].duplicate(true))
	var result: Dictionary = ReplayCodec.validate_case(fixture)
	assert_bool(result.valid).is_false()
	assert_array(result.errors).contains(["duplicate:ball_id:1"])


func test_invalid_cue_reference_and_duplicate_wall_ids_are_rejected() -> void:
	var fixture := _valid_case()
	fixture.shot_input.cue_ball_id = 99
	fixture.initial_snapshot.walls = [
		{"id": 1, "kind": "copy"}, {"id": 1, "kind": "dye"}
	]
	var result: Dictionary = ReplayCodec.validate_case(fixture)
	assert_bool(result.valid).is_false()
	assert_array(result.errors).contains(["invalid:cue_ball_id", "duplicate:wall_id:1"])


func test_out_of_bounds_ball_is_rejected() -> void:
	var fixture := _valid_case()
	fixture.initial_snapshot.balls[0].position.x = 2.0
	var result: Dictionary = ReplayCodec.validate_case(fixture)
	assert_bool(result.valid).is_false()
	assert_array(result.errors).contains(["out_of_bounds:ball:1"])


func test_non_finite_ball_value_is_rejected() -> void:
	var fixture := _valid_case()
	fixture.initial_snapshot.balls[0].position.x = NAN
	var result: Dictionary = ReplayCodec.validate_case(fixture)
	assert_bool(result.valid).is_false()
	assert_array(result.errors).contains(["non_finite:ball:1:position"])


func test_excessive_initial_overlap_is_rejected() -> void:
	var fixture := _valid_case()
	var second: Dictionary = fixture.initial_snapshot.balls[0].duplicate(true)
	second.id = 2
	second.position.x = 131.0
	fixture.initial_snapshot.balls.append(second)
	var result: Dictionary = ReplayCodec.validate_case(fixture)
	assert_bool(result.valid).is_false()
	assert_array(result.errors).contains(["overlap:ball:1:2"])


func test_canonical_hash_ignores_dictionary_insertion_order() -> void:
	var left := {"b": 2, "a": {"y": 2.00000004, "x": 1}}
	var right := {"a": {"x": 1, "y": 2.0}, "b": 2}
	assert_str(CanonicalState.hash_value(left)).is_equal(CanonicalState.hash_value(right))


func test_first_difference_identifies_path() -> void:
	var result: Dictionary = CanonicalState.first_difference(
		{"balls": [{"id": 1, "position": {"x": 10.0}}]},
		{"balls": [{"id": 1, "position": {"x": 11.0}}]}
	)
	assert_bool(result.equal).is_false()
	assert_str(result.path).is_equal("$.balls[0].position.x")


func test_legacy_m0_case_migrates_without_becoming_executable() -> void:
	var file := FileAccess.open("res://tests/golden_replay/cases/legacy_m0_contract_smoke.json", FileAccess.READ)
	assert_object(file).is_not_null()
	var legacy: Dictionary = JSON.parse_string(file.get_as_text())
	var migrated: Dictionary = ReplayCodec.migrate_legacy_m0(legacy)
	assert_int(migrated.schema_version).is_equal(1)
	assert_str(migrated.case_id).is_equal("m0-contract-smoke")
	assert_bool(migrated.executable).is_false()
	assert_str(migrated.migration_status).is_equal("legacy_contract_only")


func _valid_case() -> Dictionary:
	return {
		"schema_version": 1,
		"case_id": "contract-test",
		"physics_version": "1",
		"content_version": "m1-tech-table-1",
		"seed": 20260817,
		"initial_snapshot": {
			"revision": 0,
			"bounds": {"min": {"x": 0.0, "y": 0.0}, "max": {"x": 1000.0, "y": 620.0}},
			"balls": [{
				"id": 1, "kind": "cue", "number": 0, "color_id": "",
				"position": {"x": 130.0, "y": 315.0},
				"velocity": {"x": 0.0, "y": 0.0}, "radius": 18.0
			}],
			"walls": []
		},
		"shot_input": {"cue_ball_id": 1, "direction": {"x": 1.0, "y": 0.0}, "power_level": 3},
		"expected": {}
	}
