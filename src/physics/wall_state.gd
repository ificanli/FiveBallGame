class_name WallState
extends RefCounted

var id: int
var kind: String
var rect: Rect2
var color_id: String
var charge: int
var maximum_charge: int


func _init(
	wall_id: int = 0,
	wall_kind: String = "rail",
	wall_rect: Rect2 = Rect2(),
	wall_color_id: String = "",
	wall_charge: int = 0
) -> void:
	id = wall_id
	kind = wall_kind
	rect = wall_rect
	color_id = wall_color_id
	charge = wall_charge
	maximum_charge = wall_charge


func to_dict() -> Dictionary:
	return {
		"id": id,
		"kind": kind,
		"rect": {
			"position": {"x": rect.position.x, "y": rect.position.y},
			"size": {"x": rect.size.x, "y": rect.size.y},
		},
		"color_id": color_id,
		"charge": charge,
		"maximum_charge": maximum_charge,
	}


static func from_dict(data: Dictionary) -> WallState:
	var rect_data: Dictionary = data.get("rect", {})
	var position_data: Dictionary = rect_data.get("position", {})
	var size_data: Dictionary = rect_data.get("size", {})
	var wall := WallState.new(
		int(data.get("id", 0)),
		str(data.get("kind", "rail")),
		Rect2(
			Vector2(float(position_data.get("x", 0.0)), float(position_data.get("y", 0.0))),
			Vector2(float(size_data.get("x", 0.0)), float(size_data.get("y", 0.0)))
		),
		str(data.get("color_id", "")),
		int(data.get("maximum_charge", data.get("charge", 0)))
	)
	wall.charge = int(data.get("charge", wall.maximum_charge))
	return wall
