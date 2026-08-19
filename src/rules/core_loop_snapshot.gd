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
# M3 per-shot protection. Default values are omitted from M2 serialization/hashes.
var hand_capacity := 5
var active_bust_protection := ""
var protection_triggered := false
var forced_settle := false


static func create_tutorial(table_seed: int = 20260818) -> CoreLoopSnapshot:
	var table := TableSnapshot.new()
	table.seed = table_seed
	table.content_version = "m2-tutorial-1"
	table.balls.assign([
		BallState.new(1, "cue", 0, "", Vector2(130.0, 315.0)),
		BallState.new(2, "number", 3, "red", Vector2(340.0, 315.0)),
		BallState.new(3, "number", 4, "red", Vector2(455.0, 270.0)),
		BallState.new(4, "number", 5, "blue", Vector2(570.0, 315.0)),
		BallState.new(5, "number", 3, "yellow", Vector2(675.0, 220.0)),
		BallState.new(6, "number", 6, "red", Vector2(720.0, 390.0)),
		BallState.new(7, "number", 8, "green", Vector2(835.0, 315.0)),
	])
	table.walls.assign([
		WallState.new(1, "copy", Rect2(930.0, 140.0, 18.0, 120.0), "", 1),
		WallState.new(2, "dye", Rect2(930.0, 360.0, 18.0, 120.0), "red", 0),
	])
	return create(table, 180, 8)


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
	if hand.size() > hand_capacity or hand_capacity < 5 or hand_capacity > 6:
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
	var output := {
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
	if hand_capacity != 5 or not active_bust_protection.is_empty() or protection_triggered or forced_settle:
		output["m3_protection"] = {"hand_capacity": hand_capacity, "active": active_bust_protection, "triggered": protection_triggered, "forced_settle": forced_settle}
	return output


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
	var protection: Dictionary = data.get("m3_protection", {})
	state.hand_capacity = int(protection.get("hand_capacity", 5))
	state.active_bust_protection = str(protection.get("active", ""))
	state.protection_triggered = bool(protection.get("triggered", false))
	state.forced_settle = bool(protection.get("forced_settle", false))
	state.refresh_combo()
	return state
