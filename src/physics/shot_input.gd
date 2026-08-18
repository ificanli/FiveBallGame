class_name ShotInput
extends RefCounted

var cue_ball_id: int
var direction: Vector2
var power_level: int


func _init(ball_id: int = 0, shot_direction: Vector2 = Vector2.ZERO, level: int = 0) -> void:
	cue_ball_id = ball_id
	direction = shot_direction
	power_level = level


static func create(ball_id: int, shot_direction: Vector2, level: int) -> ShotInput:
	var normalized := shot_direction.normalized() if shot_direction.is_finite() and shot_direction.length_squared() > 0.0 else shot_direction
	return ShotInput.new(ball_id, normalized, level)


func is_valid() -> bool:
	return cue_ball_id > 0 and power_level >= 1 and power_level <= 5 and direction.is_finite() and direction.length_squared() > 0.999 and direction.length_squared() < 1.001


func initial_speed(config: PhysicsConfig) -> float:
	return config.power_speed(power_level) if is_valid() else 0.0


func to_dict() -> Dictionary:
	return {
		"cue_ball_id": cue_ball_id,
		"direction": {"x": direction.x, "y": direction.y},
		"power_level": power_level,
	}


static func from_dict(data: Dictionary) -> ShotInput:
	var direction_data: Dictionary = data.get("direction", {})
	return ShotInput.create(
		int(data.get("cue_ball_id", 0)),
		Vector2(float(direction_data.get("x", 0.0)), float(direction_data.get("y", 0.0))),
		int(data.get("power_level", 0))
	)
