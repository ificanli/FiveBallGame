class_name CoreLoopSnapshot
extends RefCounted

const SCHEMA_VERSION := 1
const RULES_VERSION := "m2-core-loop-1"
const VALID_PHASES := ["aiming", "simulating", "post_shot_decision", "won", "lost"]
const VALID_COLLECTION_STATES := ["uncollected", "hand", "waste"]

var table: TableSnapshot
var collection_states: Dictionary = {}
var hand: Array[HandSlot] = []
var score := 0
var target_score := 100
var strokes_remaining := 6
var phase := "aiming"
var shot_busted := false
var processed_event_count := 0
var combo: Dictionary = ComboEvaluator.evaluate([])
var last_rule_events: Array[Dictionary] = []


static func create(table_snapshot: TableSnapshot, target: int = 100, strokes: int = 6) -> CoreLoopSnapshot:
	var state := CoreLoopSnapshot.new()
	state.table = table_snapshot.duplicate_state()
	state.target_score = target
	state.strokes_remaining = strokes
	for ball: BallState in state.table.balls:
		if ball.kind == "number":
			state.collection_states[ball.id] = "uncollected"
	state.refresh_combo()
	return state


func refresh_combo() -> void:
	combo = ComboEvaluator.evaluate(hand)


func collection_state(ball_id: int) -> String:
	return str(collection_states.get(ball_id, "uncollected"))


func find_physical_slot(ball_id: int) -> HandSlot:
	for slot: HandSlot in hand:
		if slot.has_physical_ball and slot.physical_ball_id == ball_id:
			return slot
	return null


func duplicate_state() -> CoreLoopSnapshot:
	return CoreLoopSnapshot.from_dict(to_dict())


func validate() -> Dictionary:
	if table == null:
		return {"ok": false, "code": "missing_table"}
	if not VALID_PHASES.has(phase):
		return {"ok": false, "code": "invalid_phase"}
	if hand.size() > 5:
		return {"ok": false, "code": "hand_capacity_exceeded"}
	if score < 0 or target_score <= 0 or strokes_remaining < 0:
		return {"ok": false, "code": "invalid_counter"}
	var owned_ids: Dictionary = {}
	for slot: HandSlot in hand:
		if slot.number < 1 or slot.number > 9 or slot.color_id.is_empty():
			return {"ok": false, "code": "invalid_slot_value"}
		if slot.has_physical_ball:
			if owned_ids.has(slot.physical_ball_id):
				return {"ok": false, "code": "duplicate_physical_slot"}
			owned_ids[slot.physical_ball_id] = true
			var ball := table.find_ball(slot.physical_ball_id)
			if ball == null or ball.kind != "number":
				return {"ok": false, "code": "invalid_physical_slot"}
			if collection_state(slot.physical_ball_id) != "hand":
				return {"ok": false, "code": "slot_state_mismatch"}
	for id: Variant in collection_states:
		if not VALID_COLLECTION_STATES.has(str(collection_states[id])):
			return {"ok": false, "code": "invalid_collection_state"}
		if table.find_ball(int(id)) == null:
			return {"ok": false, "code": "orphan_collection_state"}
	for ball: BallState in table.balls:
		if not ball.position.is_finite() or not ball.velocity.is_finite():
			return {"ok": false, "code": "non_finite_ball"}
		if ball.kind == "number":
			var has_slot := find_physical_slot(ball.id) != null
			if (collection_state(ball.id) == "hand") != has_slot:
				return {"ok": false, "code": "hand_state_mismatch"}
	return {"ok": true}


func state_hash() -> String:
	return CanonicalState.hash_value(to_dict())


func to_dict() -> Dictionary:
	var slot_data: Array[Dictionary] = []
	for slot: HandSlot in hand:
		slot_data.append(slot.to_dict())
	var states := {}
	var ids := collection_states.keys()
	ids.sort()
	for id: Variant in ids:
		states[str(id)] = collection_states[id]
	return {
		"schema_version": SCHEMA_VERSION,
		"rules_version": RULES_VERSION,
		"combo_rules_version": ComboEvaluator.RULES_VERSION,
		"table": table.to_dict() if table != null else null,
		"collection_states": states,
		"hand": slot_data,
		"score": score,
		"target_score": target_score,
		"strokes_remaining": strokes_remaining,
		"phase": phase,
		"shot_busted": shot_busted,
		"processed_event_count": processed_event_count,
		"combo": combo.duplicate(true),
		"last_rule_events": last_rule_events.duplicate(true),
	}


static func from_dict(data: Dictionary) -> CoreLoopSnapshot:
	var state := CoreLoopSnapshot.new()
	var table_data: Variant = data.get("table")
	state.table = TableSnapshot.from_dict(table_data) if table_data is Dictionary else null
	for id_text: Variant in data.get("collection_states", {}):
		state.collection_states[int(id_text)] = str(data.collection_states[id_text])
	for slot_data: Dictionary in data.get("hand", []):
		state.hand.append(HandSlot.from_dict(slot_data))
	state.score = int(data.get("score", 0))
	state.target_score = int(data.get("target_score", 100))
	state.strokes_remaining = int(data.get("strokes_remaining", 6))
	state.phase = str(data.get("phase", "aiming"))
	state.shot_busted = bool(data.get("shot_busted", false))
	state.processed_event_count = int(data.get("processed_event_count", 0))
	state.last_rule_events.assign(data.get("last_rule_events", []))
	state.refresh_combo()
	return state
