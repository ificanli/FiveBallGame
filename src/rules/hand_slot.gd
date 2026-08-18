class_name HandSlot
extends RefCounted

var physical_ball_id: int
var has_physical_ball := false
var source_ball_id: int
var source_event_index: int
var number: int
var color_id: String


static func physical(ball: BallState, event_index: int = -1) -> HandSlot:
	var slot := HandSlot.new()
	slot.physical_ball_id = ball.id
	slot.has_physical_ball = true
	slot.source_ball_id = ball.id
	slot.source_event_index = event_index
	slot.number = ball.number
	slot.color_id = ball.color_id
	return slot


static func copy_of(ball: BallState, event_index: int) -> HandSlot:
	var slot := HandSlot.new()
	slot.physical_ball_id = 0
	slot.has_physical_ball = false
	slot.source_ball_id = ball.id
	slot.source_event_index = event_index
	slot.number = ball.number
	slot.color_id = ball.color_id
	return slot


func duplicate_slot() -> HandSlot:
	return HandSlot.from_dict(to_dict())


func to_dict() -> Dictionary:
	return {
		"physical_ball_id": physical_ball_id if has_physical_ball else null,
		"source_ball_id": source_ball_id,
		"source_event_index": source_event_index,
		"number": number,
		"color_id": color_id,
	}


static func from_dict(data: Dictionary) -> HandSlot:
	var slot := HandSlot.new()
	slot.has_physical_ball = data.get("physical_ball_id") != null
	slot.physical_ball_id = int(data.get("physical_ball_id", 0)) if slot.has_physical_ball else 0
	slot.source_ball_id = int(data.get("source_ball_id", slot.physical_ball_id))
	slot.source_event_index = int(data.get("source_event_index", -1))
	slot.number = int(data.get("number", 0))
	slot.color_id = str(data.get("color_id", ""))
	return slot
