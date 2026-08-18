class_name CoreLoopReducer
extends RefCounted


func apply_simulation(state: CoreLoopSnapshot, result: SimulationResult) -> Array[Dictionary]:
	var output: Array[Dictionary] = []
	state.table = result.final_snapshot.duplicate_state()
	state.processed_event_count = 0
	for index in result.events.size():
		var event: PhysicsEvent = result.events[index]
		state.processed_event_count += 1
		if state.shot_busted:
			if ["activation", "copy", "dye"].has(event.type):
				output.append(_rule_event("ignored_after_bust", event.tick, event.primary_id, {"source_type": event.type}))
			continue
		match event.type:
			"activation":
				_collect_if_needed(state, event.primary_id, event.tick, index, output)
			"copy":
				_apply_copy(state, event, index, output)
			"dye":
				_apply_dye(state, event, output)
	state.refresh_combo()
	state.last_rule_events = output.duplicate(true)
	return output


func _collect_if_needed(state: CoreLoopSnapshot, ball_id: int, tick: int, event_index: int, output: Array[Dictionary]) -> void:
	if state.collection_state(ball_id) != "uncollected":
		return
	var ball := state.table.find_ball(ball_id)
	if ball == null or ball.kind != "number":
		return
	if state.hand.size() >= 5:
		_bust(state, ball_id, tick, "physical", output)
		return
	state.collection_states[ball_id] = "hand"
	state.hand.append(HandSlot.physical(ball, event_index))
	output.append(_rule_event("collected", tick, ball_id, {"slot_index": state.hand.size() - 1}))


func _apply_copy(state: CoreLoopSnapshot, event: PhysicsEvent, event_index: int, output: Array[Dictionary]) -> void:
	if state.collection_state(event.primary_id) != "hand":
		return
	var ball := state.table.find_ball(event.primary_id)
	if ball == null:
		return
	if state.hand.size() >= 5:
		_bust(state, event.primary_id, event.tick, "copy", output)
		return
	state.hand.append(HandSlot.copy_of(ball, event_index))
	output.append(_rule_event("slot_copied", event.tick, event.primary_id, {"slot_index": state.hand.size() - 1}))


func _apply_dye(state: CoreLoopSnapshot, event: PhysicsEvent, output: Array[Dictionary]) -> void:
	if state.collection_state(event.primary_id) != "hand":
		return
	var ball := state.table.find_ball(event.primary_id)
	var slot := state.find_physical_slot(event.primary_id)
	if ball == null or slot == null:
		return
	slot.color_id = ball.color_id
	output.append(_rule_event("slot_dyed", event.tick, event.primary_id, {"color_id": ball.color_id}))


func _bust(state: CoreLoopSnapshot, trigger_ball_id: int, tick: int, source: String, output: Array[Dictionary]) -> void:
	var affected: Dictionary = {}
	for slot: HandSlot in state.hand:
		if slot.has_physical_ball:
			affected[slot.physical_ball_id] = true
	if source == "physical":
		affected[trigger_ball_id] = true
	for id: Variant in affected:
		state.collection_states[int(id)] = "waste"
	state.hand.clear()
	state.shot_busted = true
	state.refresh_combo()
	output.append(_rule_event("bust", tick, trigger_ball_id, {"source": source, "affected_ball_ids": affected.keys()}))


func _rule_event(type: String, tick: int, ball_id: int, data: Dictionary) -> Dictionary:
	return {"type": type, "tick": tick, "ball_id": ball_id, "data": data.duplicate(true)}
