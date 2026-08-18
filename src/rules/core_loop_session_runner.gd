class_name CoreLoopSessionRunner
extends RefCounted

const SCHEMA_VERSION := 1

func run(initial: CoreLoopSnapshot, commands: Array) -> Dictionary:
	var controller := CoreLoopController.new(initial.duplicate_state())
	var steps: Array[Dictionary] = []
	for command_value: Variant in commands:
		if not command_value is Dictionary:
			steps.append({"command": {}, "ok": false, "code": "invalid_command", "state_hash": controller.state.state_hash()})
			continue
		var command: Dictionary = command_value
		var type := str(command.get("type", ""))
		var outcome: Dictionary
		match type:
			"shoot":
				var direction_data: Dictionary = command.get("direction", {})
				outcome = controller.shoot(ShotInput.create(1, Vector2(float(direction_data.get("x", 0)), float(direction_data.get("y", 0))), int(command.get("power", 3))))
			"settle": outcome = controller.settle()
			"keep": outcome = controller.keep()
			"apply_events": outcome = _apply_events(controller, command.get("events", []))
			_: outcome = {"ok": false, "code": "unknown_command"}
		steps.append({
			"command": command.duplicate(true),
			"ok": bool(outcome.get("ok", false)),
			"code": str(outcome.get("code", "")),
			"state_hash": controller.state.state_hash(),
			"score": controller.state.score,
			"strokes": controller.state.strokes_remaining,
			"phase": controller.state.phase,
			"combo": controller.state.combo.duplicate(true),
			"rule_events": controller.state.last_rule_events.duplicate(true),
		})
	var result := {
		"schema_version": SCHEMA_VERSION,
		"rules_version": CoreLoopSnapshot.RULES_VERSION,
		"combo_rules_version": ComboEvaluator.RULES_VERSION,
		"steps": steps,
		"final_state": controller.state.to_dict(),
	}
	result["state_hash"] = CanonicalState.hash_value(result)
	return result

func _apply_events(controller: CoreLoopController, event_data: Array) -> Dictionary:
	if controller.state.phase != "aiming": return {"ok": false, "code": "events_not_allowed"}
	var simulation := SimulationResult.new()
	simulation.status = "success"
	simulation.final_snapshot = controller.state.table.duplicate_state()
	for item: Dictionary in event_data:
		var event := PhysicsEvent.rule_event(str(item.type), int(item.get("tick", 0)), int(item.get("ball_id", 0)), int(item.get("wall_id", 0)), item.get("data", {}))
		simulation.events.append(event)
		if event.type == "dye": simulation.final_snapshot.find_ball(event.primary_id).color_id = str(event.data.new_color_id)
	controller.state.phase = "simulating"
	var events := controller.reducer.apply_simulation(controller.state, simulation)
	controller._finish_shot_phase()
	return {"ok": true, "rule_events": events}
