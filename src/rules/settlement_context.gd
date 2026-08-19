class_name SettlementContext
extends RefCounted

var combo: Dictionary = {}
var power_level := 0
var hand_size := 0
var rail_hits := 0
var copy_count := 0
var dye_count := 0
var indirect_participant_count := 0
var participant_after_rail_count := 0
var maximum_activation_depth := 0
var dyed_participant_count := 0
var wall_kinds: Array[String] = []
var kept_then_safe := false
var final_stroke := false

static func from_values(combo_value: Dictionary, evidence: Dictionary = {}) -> SettlementContext:
	var context := SettlementContext.new()
	context.combo = combo_value.duplicate(true)
	context.power_level = int(evidence.get("power_level", 0))
	context.hand_size = int(evidence.get("hand_size", combo_value.get("participant_indices", []).size()))
	context.rail_hits = int(evidence.get("rail_hits", 0))
	context.copy_count = int(evidence.get("copy_count", 0))
	context.dye_count = int(evidence.get("dye_count", 0))
	context.indirect_participant_count = int(evidence.get("indirect_participant_count", 0))
	context.participant_after_rail_count = int(evidence.get("participant_after_rail_count", 0))
	context.maximum_activation_depth = int(evidence.get("maximum_activation_depth", 0))
	context.dyed_participant_count = int(evidence.get("dyed_participant_count", 0))
	context.wall_kinds.assign(evidence.get("wall_kinds", []))
	context.kept_then_safe = bool(evidence.get("kept_then_safe", false))
	context.final_stroke = bool(evidence.get("final_stroke", false))
	return context

func to_dict() -> Dictionary:
	return {
		"combo": combo.duplicate(true), "power_level": power_level, "hand_size": hand_size,
		"rail_hits": rail_hits, "copy_count": copy_count, "dye_count": dye_count,
		"indirect_participant_count": indirect_participant_count,
		"participant_after_rail_count": participant_after_rail_count,
		"maximum_activation_depth": maximum_activation_depth,
		"dyed_participant_count": dyed_participant_count, "wall_kinds": wall_kinds.duplicate(),
		"kept_then_safe": kept_then_safe, "final_stroke": final_stroke,
	}
