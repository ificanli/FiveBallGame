class_name ReplayCodec
extends RefCounted

const REQUIRED_FIELDS := [
	"schema_version", "case_id", "physics_version", "content_version",
	"seed", "initial_snapshot", "shot_input", "expected"
]


static func validate_case(replay_case: Dictionary) -> Dictionary:
	var errors: Array[String] = []
	for field: String in REQUIRED_FIELDS:
		if not replay_case.has(field):
			errors.append("missing:%s" % field)
	if not errors.is_empty():
		return {"valid": false, "errors": errors}
	if int(replay_case.schema_version) != 1:
		errors.append("unsupported:schema_version:%s" % str(replay_case.schema_version))
	if str(replay_case.physics_version) != PhysicsConfig.PHYSICS_VERSION:
		errors.append("unsupported:physics_version:%s" % str(replay_case.physics_version))
	var shot_data: Dictionary = replay_case.shot_input if replay_case.shot_input is Dictionary else {}
	var power_level := int(shot_data.get("power_level", 0))
	if power_level < 1 or power_level > 5:
		errors.append("invalid:power_level")
	var direction_data: Dictionary = shot_data.get("direction", {})
	var direction := Vector2(float(direction_data.get("x", 0.0)), float(direction_data.get("y", 0.0)))
	if not direction.is_finite() or direction.length_squared() <= 0.0:
		errors.append("invalid:direction")
	var snapshot_data: Dictionary = replay_case.initial_snapshot if replay_case.initial_snapshot is Dictionary else {}
	_validate_snapshot(snapshot_data, errors)
	var cue_ball_id := int(shot_data.get("cue_ball_id", 0))
	var cue_exists := false
	for ball_data: Dictionary in snapshot_data.get("balls", []):
		if int(ball_data.get("id", 0)) == cue_ball_id and str(ball_data.get("kind", "")) == "cue":
			cue_exists = true
			break
	if not cue_exists:
		errors.append("invalid:cue_ball_id")
	return {"valid": errors.is_empty(), "errors": errors}


static func _validate_snapshot(snapshot: Dictionary, errors: Array[String]) -> void:
	var ids := {}
	var validated_balls: Array[Dictionary] = []
	for ball_data: Dictionary in snapshot.get("balls", []):
		var ball_id := int(ball_data.get("id", 0))
		if ball_id <= 0:
			errors.append("invalid:ball_id:%d" % ball_id)
		elif ids.has(ball_id):
			errors.append("duplicate:ball_id:%d" % ball_id)
		else:
			ids[ball_id] = true
		var position_data: Dictionary = ball_data.get("position", {})
		var velocity_data: Dictionary = ball_data.get("velocity", {})
		var position := Vector2(float(position_data.get("x", 0.0)), float(position_data.get("y", 0.0)))
		var velocity := Vector2(float(velocity_data.get("x", 0.0)), float(velocity_data.get("y", 0.0)))
		if not position.is_finite():
			errors.append("non_finite:ball:%d:position" % ball_id)
		if not velocity.is_finite():
			errors.append("non_finite:ball:%d:velocity" % ball_id)
		var radius := float(ball_data.get("radius", 0.0))
		if not is_finite(radius) or radius <= 0.0:
			errors.append("invalid:ball:%d:radius" % ball_id)
		validated_balls.append({"id": ball_id, "position": position, "radius": radius})
	var wall_ids := {}
	for wall_data: Dictionary in snapshot.get("walls", []):
		var wall_id := int(wall_data.get("id", 0))
		if wall_id <= 0:
			errors.append("invalid:wall_id:%d" % wall_id)
		elif wall_ids.has(wall_id):
			errors.append("duplicate:wall_id:%d" % wall_id)
		else:
			wall_ids[wall_id] = true
	var bounds_data: Dictionary = snapshot.get("bounds", {})
	var min_data: Dictionary = bounds_data.get("min", {})
	var max_data: Dictionary = bounds_data.get("max", {})
	var minimum := Vector2(float(min_data.get("x", NAN)), float(min_data.get("y", NAN)))
	var maximum := Vector2(float(max_data.get("x", NAN)), float(max_data.get("y", NAN)))
	if not minimum.is_finite() or not maximum.is_finite() or minimum.x >= maximum.x or minimum.y >= maximum.y:
		errors.append("invalid:bounds")
	else:
		for ball: Dictionary in validated_balls:
			if ball.position.is_finite() and (
				ball.position.x - ball.radius < minimum.x or ball.position.y - ball.radius < minimum.y
				or ball.position.x + ball.radius > maximum.x or ball.position.y + ball.radius > maximum.y
			):
				errors.append("out_of_bounds:ball:%d" % ball.id)
	for first_index in validated_balls.size():
		for second_index in range(first_index + 1, validated_balls.size()):
			var first: Dictionary = validated_balls[first_index]
			var second: Dictionary = validated_balls[second_index]
			if not first.position.is_finite() or not second.position.is_finite():
				continue
			var minimum_distance: float = maxf(0.0, first.radius + second.radius - 2.0)
			if first.position.distance_to(second.position) < minimum_distance:
				errors.append("overlap:ball:%d:%d" % [mini(first.id, second.id), maxi(first.id, second.id)])


static func load_case(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {"ok": false, "error": "open_failed", "path": path}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return {"ok": false, "error": "invalid_json", "path": path}
	var validation := validate_case(parsed)
	if not validation.valid:
		return {"ok": false, "error": "validation_failed", "errors": validation.errors, "path": path}
	return {"ok": true, "case": parsed}


static func migrate_legacy_m0(legacy: Dictionary) -> Dictionary:
	return {
		"schema_version": 1,
		"case_id": str(legacy.get("case_id", "legacy-m0")),
		"executable": false,
		"migration_status": "legacy_contract_only",
		"legacy_input": legacy.get("input", {}).duplicate(true),
		"legacy_expected": legacy.get("expected", {}).duplicate(true),
	}
