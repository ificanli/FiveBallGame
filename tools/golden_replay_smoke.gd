extends SceneTree

const CASE_PATH := "res://tests/golden_replay/cases/m0_contract_smoke.json"


func _init() -> void:
	var file := FileAccess.open(CASE_PATH, FileAccess.READ)
	if file == null:
		_finish({"status": "error", "case": CASE_PATH, "reason": "open_failed"}, 1)
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		_finish({"status": "error", "case": CASE_PATH, "reason": "invalid_json"}, 1)
		return
	var required := ["schema_version", "case_id", "input", "expected"]
	for key: String in required:
		if not parsed.has(key):
			_finish({"status": "error", "case": CASE_PATH, "reason": "missing_%s" % key}, 1)
			return
	_finish({
		"status": "contract_loaded",
		"case_id": parsed["case_id"],
		"schema_version": parsed["schema_version"],
		"physics_executed": false,
		"expected": parsed["expected"]
	}, 0)


func _finish(result: Dictionary, code: int) -> void:
	print(JSON.stringify(result))
	quit(code)
