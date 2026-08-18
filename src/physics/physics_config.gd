class_name PhysicsConfig
extends RefCounted

const PHYSICS_VERSION := "1"

var fixed_delta := 1.0 / 120.0
var ball_restitution := 0.95
var rail_restitution := 0.90
var drag_per_tick := pow(0.992, 0.5)
var stop_speed := 2.0
var low_speed_threshold := 12.0
var low_speed_finish_seconds := 0.35
var maximum_shot_seconds := 6.0
var maximum_substeps := 8
var comparison_grid := 0.0001
var power_speeds := PackedFloat64Array([330.0, 495.0, 660.0, 858.0, 1100.0])


static func default_config() -> PhysicsConfig:
	return PhysicsConfig.new()


func power_speed(level: int) -> float:
	if level < 1 or level > power_speeds.size():
		return 0.0
	return power_speeds[level - 1]


func to_dict() -> Dictionary:
	return {
		"physics_version": PHYSICS_VERSION,
		"fixed_delta": fixed_delta,
		"ball_restitution": ball_restitution,
		"rail_restitution": rail_restitution,
		"drag_per_tick": drag_per_tick,
		"stop_speed": stop_speed,
		"low_speed_threshold": low_speed_threshold,
		"low_speed_finish_seconds": low_speed_finish_seconds,
		"maximum_shot_seconds": maximum_shot_seconds,
		"maximum_substeps": maximum_substeps,
		"comparison_grid": comparison_grid,
		"power_speeds": Array(power_speeds),
	}
