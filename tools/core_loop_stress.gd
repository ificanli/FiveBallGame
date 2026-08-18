extends SceneTree

func _init() -> void:
	var sessions := 0
	for seed_offset in 20:
		for power in range(1, 6):
			var baseline_hash := ""
			for repeat in 5:
				var state := CoreLoopSnapshot.create_tutorial(20260818 + seed_offset)
				var controller := CoreLoopController.new(state)
				for shot_index in 4:
					if state.phase != "aiming":
						if state.phase == "post_shot_decision": controller.keep() if shot_index < 3 else controller.settle()
						else: break
					if state.phase == "aiming": controller.shoot(ShotInput.create(1, Vector2.RIGHT.rotated(0.13 * shot_index), power))
				if not state.validate().ok:
					_fail("invalid_state", seed_offset, power, repeat)
					return
				for ball: BallState in state.table.balls:
					if not ball.position.is_finite() or not ball.velocity.is_finite():
						_fail("non_finite", seed_offset, power, repeat)
						return
				var hash := state.state_hash()
				if repeat == 0: baseline_hash = hash
				elif hash != baseline_hash:
					_fail("drift", seed_offset, power, repeat)
					return
				sessions += 1
	print(JSON.stringify({"status": "success", "sessions": sessions, "powers": 5, "seeds": 20, "repeats": 5}))
	quit(0)

func _fail(reason: String, seed: int, power: int, repeat: int) -> void:
	print(JSON.stringify({"status": "error", "reason": reason, "seed": seed, "power": power, "repeat": repeat}))
	quit(1)
