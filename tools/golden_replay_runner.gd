extends SceneTree

const CASE_DIR := "res://tests/golden_replay/cases"
const MANIFEST_PATH := "res://tests/golden_replay/manifest.json"
const OUTPUT_DIR := "res://tests/golden_replay/output"
const ReplayRunnerScript := preload("res://src/physics/replay_runner.gd")
const CanonicalStateScript := preload("res://src/physics/canonical_state.gd")


func _init() -> void:
	var arguments := OS.get_cmdline_user_args()
	var update := arguments.has("--update")
	var repeat_count := _argument_int(arguments, "--repeat", 1)
	var output_path := _argument_value(arguments, "--output", "")
	var manifest := _load_json(MANIFEST_PATH)
	if not manifest.ok:
		_finish({"status": "failed", "reason": "manifest", "detail": manifest}, 1, output_path)
		return
	var audit := _audit_manifest(manifest.data)
	if not audit.ok:
		_finish({"status": "failed", "reason": "coverage", "detail": audit}, 1, output_path)
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))
	var runner := ReplayRunnerScript.new()
	var case_results: Array[Dictionary] = []
	var failures: Array[Dictionary] = []
	for case_entry: Dictionary in manifest.data.cases:
		var path := "%s/%s" % [CASE_DIR, case_entry.file]
		var loaded := _load_json(path)
		if not loaded.ok:
			failures.append({"case_id": case_entry.id, "reason": "load", "detail": loaded})
			continue
		var actual := runner.execute_case(loaded.data)
		if actual.status != "success":
			failures.append({"case_id": case_entry.id, "reason": actual.status, "detail": actual})
			continue
		if update:
			loaded.data.expected = runner.comparable_output(actual)
			_write_json(path, loaded.data)
		else:
			var comparison := runner.compare_case(loaded.data)
			if not comparison.passed:
				failures.append({"case_id": case_entry.id, "reason": "golden_difference", "difference": comparison.difference})
		var repeat_failure := _repeat_case(runner, loaded.data, actual, repeat_count)
		if not repeat_failure.is_empty():
			failures.append(repeat_failure)
		case_results.append(runner.comparable_output(actual).merged({"case_id": case_entry.id}))
	var output := {
		"status": "passed" if failures.is_empty() else "failed",
		"updated": update,
		"case_count": case_results.size(),
		"repeat_count": repeat_count,
		"coverage": audit,
		"cases": case_results,
		"failures": failures,
	}
	_finish(output, 0 if failures.is_empty() else 1, output_path)


func _repeat_case(runner: RefCounted, case_data: Dictionary, baseline: Dictionary, repeat_count: int) -> Dictionary:
	for repeat_index in range(1, repeat_count):
		var repeated: Dictionary = runner.execute_case(case_data)
		var difference: Dictionary = CanonicalStateScript.first_difference(runner.comparable_output(baseline), runner.comparable_output(repeated))
		if not difference.equal:
			return {
				"case_id": baseline.case_id,
				"reason": "repeat_divergence",
				"repeat": repeat_index,
				"difference": difference,
			}
	return {}


func _audit_manifest(manifest: Dictionary) -> Dictionary:
	var cases: Array = manifest.get("cases", [])
	var minimum := int(manifest.get("minimum_cases", 0))
	var maximum := int(manifest.get("maximum_cases", 999))
	var found := {}
	for case_entry: Dictionary in cases:
		for category: Variant in case_entry.get("categories", []):
			found[str(category)] = true
	var missing: Array[String] = []
	for required: Variant in manifest.get("required_categories", []):
		if not found.has(str(required)):
			missing.append(str(required))
	return {
		"ok": cases.size() >= minimum and cases.size() <= maximum and missing.is_empty(),
		"case_count": cases.size(),
		"minimum": minimum,
		"maximum": maximum,
		"missing_categories": missing,
	}


func _load_json(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {"ok": false, "path": path, "error": "open_failed"}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return {"ok": false, "path": path, "error": "invalid_json"}
	return {"ok": true, "data": parsed}


func _write_json(path: String, data: Dictionary) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "  ", false, true) + "\n")


func _argument_value(arguments: PackedStringArray, name: String, fallback: String) -> String:
	var index := arguments.find(name)
	return arguments[index + 1] if index >= 0 and index + 1 < arguments.size() else fallback


func _argument_int(arguments: PackedStringArray, name: String, fallback: int) -> int:
	return int(_argument_value(arguments, name, str(fallback)))


func _finish(output: Dictionary, exit_code: int, output_path: String) -> void:
	var text := JSON.stringify(output)
	print(text)
	if not output_path.is_empty():
		var absolute := ProjectSettings.globalize_path(output_path) if output_path.begins_with("res://") else output_path
		DirAccess.make_dir_recursive_absolute(absolute.get_base_dir())
		var file := FileAccess.open(absolute, FileAccess.WRITE)
		if file != null:
			file.store_string(JSON.stringify(output, "  ", false, true) + "\n")
	quit(exit_code)
