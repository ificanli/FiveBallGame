class_name BallState
extends RefCounted

var id: int
var kind: String
var number: int
var color_id: String
var position: Vector2
var velocity: Vector2
var radius: float
var active: bool
var activation_source_id: int


func _init(
	ball_id: int = 0,
	ball_kind: String = "number",
	ball_number: int = 0,
	ball_color_id: String = "",
	ball_position: Vector2 = Vector2.ZERO,
	ball_velocity: Vector2 = Vector2.ZERO,
	ball_radius: float = 18.0
) -> void:
	id = ball_id
	kind = ball_kind
	number = ball_number
	color_id = ball_color_id
	position = ball_position
	velocity = ball_velocity
	radius = ball_radius
	active = false
	activation_source_id = 0


func duplicate_state() -> BallState:
	return BallState.from_dict(to_dict())


func to_dict() -> Dictionary:
	return {
		"id": id,
		"kind": kind,
		"number": number,
		"color_id": color_id,
		"position": {"x": position.x, "y": position.y},
		"velocity": {"x": velocity.x, "y": velocity.y},
		"radius": radius,
		"active": active,
		"activation_source_id": activation_source_id,
	}


static func from_dict(data: Dictionary) -> BallState:
	var position_data: Dictionary = data.get("position", {})
	var velocity_data: Dictionary = data.get("velocity", {})
	var ball := BallState.new(
		int(data.get("id", 0)),
		str(data.get("kind", "number")),
		int(data.get("number", 0)),
		str(data.get("color_id", "")),
		Vector2(float(position_data.get("x", 0.0)), float(position_data.get("y", 0.0))),
		Vector2(float(velocity_data.get("x", 0.0)), float(velocity_data.get("y", 0.0))),
		float(data.get("radius", 18.0))
	)
	ball.active = bool(data.get("active", false))
	ball.activation_source_id = int(data.get("activation_source_id", 0))
	return ball
