class_name SimulationResult
extends RefCounted

var status := "pending"
var ticks := 0
var stop_reason := ""
var events: Array[PhysicsEvent] = []
var final_snapshot: TableSnapshot
var state_hash := ""
var trajectories: Dictionary = {}
var error: Dictionary = {}


func to_dict() -> Dictionary:
	var event_data: Array[Dictionary] = []
	for event: PhysicsEvent in events:
		event_data.append(event.to_dict())
	return {
		"status": status,
		"ticks": ticks,
		"stop_reason": stop_reason,
		"events": event_data,
		"final_snapshot": final_snapshot.to_dict() if final_snapshot != null else null,
		"state_hash": state_hash,
		"trajectories": trajectories.duplicate(true),
		"error": error.duplicate(true),
	}
