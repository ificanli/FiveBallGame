class_name TrajectoryPreview
extends RefCounted

const MODE_BUDGETS := {"concise": 90, "standard": 270, "full": 480}

var _cache: Dictionary = {}
var _latest_request_id := -1


func request(snapshot: TableSnapshot, shot: ShotInput, mode: String, request_id: int) -> Dictionary:
	if request_id < _latest_request_id:
		return {"ok": false, "canceled": true, "request_id": request_id}
	_latest_request_id = request_id
	if not MODE_BUDGETS.has(mode):
		return {"ok": false, "canceled": false, "error": "invalid_mode", "mode": mode}
	if not shot.is_valid():
		return {"ok": false, "canceled": false, "error": "invalid_shot"}
	var tick_budget: int = MODE_BUDGETS[mode]
	var cache_key := CanonicalState.hash_value({
		"revision": snapshot.revision,
		"snapshot": snapshot.to_dict(),
		"shot": shot.to_dict(),
		"mode": mode,
	})
	if _cache.has(cache_key):
		var cached: Dictionary = _cache[cache_key].duplicate(true)
		cached.cache_hit = true
		cached.request_id = request_id
		return cached
	var result := PhysicsSimulator.new().simulate(snapshot, shot, null, tick_budget, true)
	var event_data: Array[Dictionary] = []
	for event: PhysicsEvent in result.events:
		event_data.append(event.to_dict())
	var first_event := {}
	for event: PhysicsEvent in result.events:
		if event.type in ["ball_collision", "rail_collision", "wall_collision"]:
			first_event = event.to_dict()
			break
	var output := {
		"ok": result.status == "success",
		"canceled": false,
		"cache_hit": false,
		"request_id": request_id,
		"mode": mode,
		"tick_budget": tick_budget,
		"ticks": result.ticks,
		"stop_reason": result.stop_reason,
		"first_event": first_event,
		"events": event_data,
		"trajectories": _trim_trajectories(result.trajectories, mode),
		"state_hash": result.state_hash,
	}
	_cache[cache_key] = output.duplicate(true)
	return output


func clear_cache() -> void:
	_cache.clear()


func _trim_trajectories(trajectories: Dictionary, mode: String) -> Dictionary:
	if mode == "full":
		return trajectories.duplicate(true)
	var output := {}
	var maximum_samples := 120 if mode == "standard" else 48
	for key: Variant in trajectories:
		var samples: Array = trajectories[key]
		output[key] = samples.slice(0, mini(samples.size(), maximum_samples))
	return output
