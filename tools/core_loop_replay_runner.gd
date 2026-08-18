extends SceneTree

func _init() -> void:
	var args := OS.get_cmdline_user_args()
	var repeat_count := 100
	var output_path := "core-loop-local.json"
	for index in args.size():
		if args[index] == "--repeat" and index + 1 < args.size(): repeat_count = int(args[index + 1])
		if args[index] == "--output" and index + 1 < args.size(): output_path = args[index + 1]
	var cases := _cases()
	var results: Array[Dictionary] = []
	for case: Dictionary in cases:
		var baseline: Dictionary = CoreLoopSessionRunner.new().run(case.initial, case.commands)
		for iteration in repeat_count:
			var repeated := CoreLoopSessionRunner.new().run(case.initial, case.commands)
			if repeated.state_hash != baseline.state_hash:
				print(JSON.stringify({"status": "drift", "case_id": case.id, "iteration": iteration}))
				quit(1)
				return
		results.append({"case_id": case.id, "state_hash": baseline.state_hash, "steps": baseline.steps.size(), "phase": baseline.final_state.phase, "score": baseline.final_state.score})
	var payload := {"status": "success", "repeat": repeat_count, "schema_version": 1, "cases": results}
	var absolute_output := ProjectSettings.globalize_path(output_path) if output_path.begins_with("res://") else output_path
	DirAccess.make_dir_recursive_absolute(absolute_output.get_base_dir())
	var file := FileAccess.open(absolute_output, FileAccess.WRITE)
	if file == null:
		print(JSON.stringify({"status": "error", "reason": "open_output_failed"}))
		quit(1)
		return
	file.store_string(CanonicalState.canonical_json(payload))
	print(JSON.stringify(payload))
	quit(0)

func _cases() -> Array[Dictionary]:
	var settle := CoreLoopSnapshot.create_tutorial()
	settle.table.balls = [settle.table.find_ball(1), settle.table.find_ball(2)]
	settle.collection_states = {2: "uncollected"}
	settle.target_score = 3
	settle.strokes_remaining = 1
	var keep := CoreLoopSnapshot.create_tutorial()
	keep.table.balls = [keep.table.find_ball(1), keep.table.find_ball(2), keep.table.find_ball(3)]
	keep.collection_states = {2: "uncollected", 3: "uncollected"}
	keep.target_score = 100
	keep.strokes_remaining = 2
	var wall := CoreLoopSnapshot.create_tutorial()
	var five := CoreLoopSnapshot.create_tutorial()
	for id in range(2, 7):
		five.collection_states[id] = "hand"
		five.hand.append(HandSlot.physical(five.table.find_ball(id)))
	five.refresh_combo()
	return [
		{"id": "settle", "initial": settle, "commands": [{"type": "shoot", "direction": {"x": 1, "y": 0}, "power": 3}, {"type": "settle"}]},
		{"id": "keep-then-score", "initial": keep, "commands": [{"type": "shoot", "direction": {"x": 1, "y": 0}, "power": 2}, {"type": "keep"}, {"type": "shoot", "direction": {"x": 1, "y": 0}, "power": 2}, {"type": "settle"}]},
		{"id": "final-stroke-win", "initial": settle.duplicate_state(), "commands": [{"type": "shoot", "direction": {"x": 1, "y": 0}, "power": 3}, {"type": "settle"}]},
		{"id": "final-stroke-loss", "initial": settle.duplicate_state(), "commands": [{"type": "shoot", "direction": {"x": 0, "y": -1}, "power": 1}]},
		{"id": "dye-sync", "initial": wall, "commands": [{"type": "apply_events", "events": [{"type": "activation", "ball_id": 2}, {"type": "dye", "ball_id": 2, "wall_id": 2, "data": {"old_color_id": "red", "new_color_id": "blue"}}]}]},
		{"id": "copy-wall-bust", "initial": five, "commands": [{"type": "apply_events", "events": [{"type": "copy", "ball_id": 2, "wall_id": 1, "data": {"number": 3, "color_id": "red"}}]}]},
		{"id": "physical-sixth-bust", "initial": five.duplicate_state(), "commands": [{"type": "apply_events", "events": [{"type": "activation", "ball_id": 7}]}]},
		{"id": "waste-later-collision", "initial": _waste_state(), "commands": [{"type": "shoot", "direction": {"x": 1, "y": 0}, "power": 2}]},
	]

func _waste_state() -> CoreLoopSnapshot:
	var state := CoreLoopSnapshot.create_tutorial()
	state.collection_states[2] = "waste"
	return state
