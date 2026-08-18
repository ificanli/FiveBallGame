class_name PhysicsEvent
extends RefCounted

var tick: int
var type: String
var primary_id: int
var secondary_id: int
var point: Vector2
var data: Dictionary


func _init(event_type: String = "", event_tick: int = 0) -> void:
	type = event_type
	tick = event_tick
	primary_id = 0
	secondary_id = 0
	point = Vector2.ZERO
	data = {}


static func ball_collision(event_tick: int, first_id: int, second_id: int, contact_point: Vector2) -> PhysicsEvent:
	var event := PhysicsEvent.new("ball_collision", event_tick)
	event.primary_id = mini(first_id, second_id)
	event.secondary_id = maxi(first_id, second_id)
	event.point = contact_point
	return event


static func rail_collision(event_tick: int, ball_id: int, rail_name: String, contact_point: Vector2) -> PhysicsEvent:
	var event := PhysicsEvent.new("rail_collision", event_tick)
	event.primary_id = ball_id
	event.point = contact_point
	event.data = {"rail": rail_name}
	return event


static func wall_collision(event_tick: int, ball_id: int, wall_id: int, contact_point: Vector2) -> PhysicsEvent:
	var event := PhysicsEvent.new("wall_collision", event_tick)
	event.primary_id = ball_id
	event.secondary_id = wall_id
	event.point = contact_point
	return event


static func rule_event(event_type: String, event_tick: int, ball_id: int, wall_id: int = 0, event_data: Dictionary = {}) -> PhysicsEvent:
	var event := PhysicsEvent.new(event_type, event_tick)
	event.primary_id = ball_id
	event.secondary_id = wall_id
	event.data = event_data.duplicate(true)
	return event


func to_dict() -> Dictionary:
	return {
		"tick": tick,
		"type": type,
		"primary_id": primary_id,
		"secondary_id": secondary_id,
		"point": {"x": point.x, "y": point.y},
		"data": data.duplicate(true),
	}
