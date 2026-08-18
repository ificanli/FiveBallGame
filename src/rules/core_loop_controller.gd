class_name CoreLoopController
extends RefCounted

var state: CoreLoopSnapshot
var last_simulation: SimulationResult
var reducer := CoreLoopReducer.new()


func _init(initial_state: CoreLoopSnapshot = null) -> void:
	state = initial_state


func shoot(shot: ShotInput, capture_trajectories: bool = false) -> Dictionary:
	if state == null:
		return _reject("missing_state")
	if state.phase != "aiming":
		return _reject("shoot_not_allowed")
	if state.strokes_remaining <= 0:
		return _reject("no_strokes_remaining")
	if not shot.is_valid():
		return _reject("invalid_shot")
	state.strokes_remaining -= 1
	state.phase = "simulating"
	state.shot_busted = false
	state.last_rule_events.clear()
	_prepare_physics_eligibility()
	last_simulation = PhysicsSimulator.new().simulate(state.table, shot, null, -1, capture_trajectories)
	if last_simulation.status != "success":
		state.strokes_remaining += 1
		state.phase = "aiming"
		return _reject(str(last_simulation.error.get("code", "simulation_error")))
	var rule_events := reducer.apply_simulation(state, last_simulation)
	_finish_shot_phase()
	return {"ok": true, "simulation": last_simulation, "rule_events": rule_events, "state": state}


func settle() -> Dictionary:
	if state == null or state.phase != "post_shot_decision" or state.hand.is_empty():
		return _reject("settle_not_allowed")
	var banked := int(state.combo.score)
	state.score += banked
	_forget_hand_as_waste()
	state.hand.clear()
	state.refresh_combo()
	if state.score >= state.target_score:
		state.phase = "won"
	elif state.strokes_remaining <= 0:
		state.phase = "lost"
	else:
		state.phase = "aiming"
	state.last_rule_events = [{"type": "settled", "score": banked}]
	return {"ok": true, "banked_score": banked, "state": state}


func keep() -> Dictionary:
	if state == null or state.phase != "post_shot_decision":
		return _reject("keep_not_allowed")
	if state.strokes_remaining <= 0:
		return _reject("no_strokes_remaining")
	state.phase = "aiming"
	state.last_rule_events = [{"type": "kept", "hand_size": state.hand.size()}]
	return {"ok": true, "state": state}


func allowed_actions() -> Array[String]:
	if state == null:
		return []
	match state.phase:
		"aiming":
			return ["shoot", "reset"] if state.strokes_remaining > 0 else ["reset"]
		"post_shot_decision":
			var actions: Array[String] = ["settle", "reset"]
			if state.strokes_remaining > 0:
				actions.insert(1, "keep")
			return actions
		"won", "lost":
			return ["reset"]
	return []


func _prepare_physics_eligibility() -> void:
	state.table.rule_ineligible_ball_ids.clear()
	for id: Variant in state.collection_states:
		if state.collection_state(int(id)) == "waste":
			state.table.rule_ineligible_ball_ids[int(id)] = true


func _finish_shot_phase() -> void:
	if state.shot_busted:
		state.phase = "lost" if state.strokes_remaining <= 0 and state.score < state.target_score else "aiming"
	elif not state.hand.is_empty():
		state.phase = "post_shot_decision"
	elif state.strokes_remaining <= 0:
		state.phase = "lost"
	else:
		state.phase = "aiming"


func _forget_hand_as_waste() -> void:
	for slot: HandSlot in state.hand:
		if slot.has_physical_ball:
			state.collection_states[slot.physical_ball_id] = "waste"


func _reject(code: String) -> Dictionary:
	return {"ok": false, "code": code, "state": state}
