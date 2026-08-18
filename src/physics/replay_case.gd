class_name ReplayCase
extends RefCounted

var schema_version := 1
var case_id := ""
var categories: Array[String] = []
var physics_version := PhysicsConfig.PHYSICS_VERSION
var content_version := TableSnapshot.CONTENT_VERSION
var seed: int
var initial_snapshot: TableSnapshot
var shot_input: ShotInput
var expected: Dictionary = {}


static func from_dict(data: Dictionary) -> ReplayCase:
	var replay := ReplayCase.new()
	replay.schema_version = int(data.get("schema_version", 1))
	replay.case_id = str(data.get("case_id", ""))
	for category: Variant in data.get("categories", []):
		replay.categories.append(str(category))
	replay.physics_version = str(data.get("physics_version", PhysicsConfig.PHYSICS_VERSION))
	replay.content_version = str(data.get("content_version", TableSnapshot.CONTENT_VERSION))
	replay.seed = int(data.get("seed", 0))
	replay.initial_snapshot = TableSnapshot.from_dict(data.get("initial_snapshot", {}))
	replay.shot_input = ShotInput.from_dict(data.get("shot_input", {}))
	replay.expected = data.get("expected", {}).duplicate(true)
	return replay


func to_dict() -> Dictionary:
	return {
		"schema_version": schema_version,
		"case_id": case_id,
		"categories": categories.duplicate(),
		"physics_version": physics_version,
		"content_version": content_version,
		"seed": seed,
		"initial_snapshot": initial_snapshot.to_dict(),
		"shot_input": shot_input.to_dict(),
		"expected": expected.duplicate(true),
	}
