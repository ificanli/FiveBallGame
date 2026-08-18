extends SceneTree

const ITERATIONS := 100


func _init() -> void:
	var snapshot := TableSnapshot.create_seeded_technical_table(20260817)
	var shot := ShotInput.create(1, Vector2(1.0, -0.18), 4)
	var modes := ["concise", "standard", "full"]
	var results := {}
	for mode: String in modes:
		var started := Time.get_ticks_usec()
		for index in ITERATIONS:
			var service := TrajectoryPreview.new()
			var preview: Dictionary = service.request(snapshot, shot, mode, index)
			if not preview.ok:
				print(JSON.stringify({"status": "failed", "mode": mode, "result": preview}))
				quit(1)
				return
		var elapsed_us := Time.get_ticks_usec() - started
		results[mode] = {
			"iterations": ITERATIONS,
			"total_ms": elapsed_us / 1000.0,
			"average_ms": elapsed_us / 1000.0 / ITERATIONS,
			"tick_budget": TrajectoryPreview.MODE_BUDGETS[mode],
		}
	print(JSON.stringify({"status": "passed", "results": results}))
	quit(0)
