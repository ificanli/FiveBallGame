class_name TableSnapshot
extends RefCounted

const CONTENT_VERSION := "m1-tech-table-1"

var schema_version := 1
var physics_version := PhysicsConfig.PHYSICS_VERSION
var content_version := CONTENT_VERSION
var seed: int
var revision: int
var bounds: Rect2
var balls: Array[BallState] = []
var walls: Array[WallState] = []


func _init() -> void:
	seed = 0
	revision = 0
	bounds = Rect2(Vector2.ZERO, Vector2(1000.0, 620.0))


static func create_seeded_technical_table(table_seed: int) -> TableSnapshot:
	var snapshot := TableSnapshot.new()
	snapshot.seed = table_seed
	var ids := StableIdAllocator.new(1)
	snapshot.balls.append(BallState.new(ids.next_id(), "cue", 0, "", Vector2(130.0, 315.0)))
	var rng := RandomNumberGenerator.new()
	rng.seed = table_seed
	var colors := ["red", "blue", "yellow", "green"]
	var anchors := [
		Vector2(340.0, 220.0), Vector2(430.0, 315.0), Vector2(530.0, 210.0),
		Vector2(620.0, 350.0), Vector2(720.0, 250.0), Vector2(810.0, 390.0)
	]
	for index in anchors.size():
		var number := rng.randi_range(1, 9)
		var color_id: String = colors[rng.randi_range(0, colors.size() - 1)]
		snapshot.balls.append(BallState.new(ids.next_id(), "number", number, color_id, anchors[index]))
	var wall_ids := StableIdAllocator.new(1)
	snapshot.walls.append(WallState.new(wall_ids.next_id(), "copy", Rect2(930.0, 140.0, 18.0, 120.0), "", 1))
	snapshot.walls.append(WallState.new(wall_ids.next_id(), "dye", Rect2(930.0, 360.0, 18.0, 120.0), "red", 0))
	return snapshot


func duplicate_state() -> TableSnapshot:
	return TableSnapshot.from_dict(to_dict())


func find_ball(ball_id: int) -> BallState:
	for ball: BallState in balls:
		if ball.id == ball_id:
			return ball
	return null


func to_dict() -> Dictionary:
	var ball_data: Array[Dictionary] = []
	for ball: BallState in balls:
		ball_data.append(ball.to_dict())
	var wall_data: Array[Dictionary] = []
	for wall: WallState in walls:
		wall_data.append(wall.to_dict())
	return {
		"schema_version": schema_version,
		"physics_version": physics_version,
		"content_version": content_version,
		"seed": seed,
		"revision": revision,
		"bounds": {
			"min": {"x": bounds.position.x, "y": bounds.position.y},
			"max": {"x": bounds.end.x, "y": bounds.end.y},
		},
		"balls": ball_data,
		"walls": wall_data,
	}


static func from_dict(data: Dictionary) -> TableSnapshot:
	var snapshot := TableSnapshot.new()
	snapshot.schema_version = int(data.get("schema_version", 1))
	snapshot.physics_version = str(data.get("physics_version", PhysicsConfig.PHYSICS_VERSION))
	snapshot.content_version = str(data.get("content_version", CONTENT_VERSION))
	snapshot.seed = int(data.get("seed", 0))
	snapshot.revision = int(data.get("revision", 0))
	var bounds_data: Dictionary = data.get("bounds", {})
	var min_data: Dictionary = bounds_data.get("min", {})
	var max_data: Dictionary = bounds_data.get("max", {})
	var minimum := Vector2(float(min_data.get("x", 0.0)), float(min_data.get("y", 0.0)))
	var maximum := Vector2(float(max_data.get("x", 1000.0)), float(max_data.get("y", 620.0)))
	snapshot.bounds = Rect2(minimum, maximum - minimum)
	for ball_data: Dictionary in data.get("balls", []):
		snapshot.balls.append(BallState.from_dict(ball_data))
	for wall_data: Dictionary in data.get("walls", []):
		snapshot.walls.append(WallState.from_dict(wall_data))
	return snapshot
