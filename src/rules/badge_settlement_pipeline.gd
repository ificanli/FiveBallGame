class_name BadgeSettlementPipeline
extends RefCounted

const MAX_SCORE := 2_000_000_000

static func evaluate(context: SettlementContext, badge_ids: Array[String], growth: Dictionary = {}) -> Dictionary:
	var base_add := 0
	var multiplier_add := 0
	var multiplier_percent := 100
	var steps: Array[Dictionary] = []
	var growth_changes := {}
	for badge_id in badge_ids:
		var badge := BadgeCatalog.get_badge(badge_id)
		if badge.is_empty():
			steps.append(_step(badge_id, false, "unknown_badge", base_add, multiplier_add, multiplier_percent))
			continue
		var result := _apply_badge(badge, context, growth, base_add, multiplier_add, multiplier_percent)
		base_add = result.base_add
		multiplier_add = result.multiplier_add
		multiplier_percent = result.multiplier_percent
		if result.growth_delta > 0:
			growth_changes[badge_id] = int(growth.get(badge_id, 0)) + result.growth_delta
		steps.append({
			"badge_id": badge_id, "triggered": result.triggered, "evidence": result.evidence,
			"base_add": base_add, "multiplier_add": multiplier_add,
			"multiplier_percent": multiplier_percent, "growth_delta": result.growth_delta,
		})
	var number_sum := int(context.combo.get("number_sum", 0))
	var combo_multiplier := int(context.combo.get("multiplier", 0))
	var subtotal := maxi(0, number_sum + base_add) * maxi(0, combo_multiplier + multiplier_add)
	var final_score := mini(MAX_SCORE, int(round(float(subtotal) * float(multiplier_percent) / 100.0)))
	return {
		"rules_version": BadgeCatalog.VERSION, "number_sum": number_sum,
		"combo_multiplier": combo_multiplier, "base_add": base_add,
		"multiplier_add": multiplier_add, "multiplier_percent": multiplier_percent,
		"base_score": int(context.combo.get("score", 0)), "final_score": final_score,
		"steps": steps, "growth_changes": growth_changes,
	}

static func _apply_badge(badge: Dictionary, c: SettlementContext, growth: Dictionary, base: int, add: int, percent: int) -> Dictionary:
	var count := 0
	var triggered := false
	var evidence := ""
	match badge.condition:
		"combo_pair": triggered = c.combo.get("type") == "pair"
		"straight_4_plus": triggered = ["straight", "same_color_straight"].has(c.combo.get("type")) and c.combo.get("participant_indices", []).size() >= 4
		"same_color_participant": count = c.combo.get("participant_indices", []).size() if ["same_color", "same_color_straight"].has(c.combo.get("type")) else 0; triggered = count > 0
		"no_pollution": triggered = c.hand_size > 0 and c.combo.get("pollution_indices", []).is_empty()
		"matching_three_plus": triggered = ["three_of_a_kind", "bomb", "five_ball_grand_slam"].has(c.combo.get("type"))
		"same_color_straight": triggered = c.combo.get("type") == "same_color_straight"
		"rail_hits": count = mini(c.rail_hits, 6); triggered = count > 0
		"power_five_three_slots": triggered = c.power_level == 5 and c.combo.get("participant_indices", []).size() >= 3
		"power_one_two_slots": triggered = c.power_level == 1 and c.combo.get("participant_indices", []).size() >= 2
		"indirect_participants": count = c.indirect_participant_count; triggered = count > 0
		"participant_after_rail": count = c.participant_after_rail_count; triggered = count > 0
		"activation_depth": count = maxi(0, c.maximum_activation_depth - 1); triggered = count > 0
		"copy_count": count = c.copy_count; triggered = count > 0
		"dyed_participants": count = c.dyed_participant_count; triggered = count > 0
		"always": triggered = true
		"two_wall_kinds": triggered = c.wall_kinds.size() >= 2
		"five_slots": triggered = c.hand_size == 5
		"kept_then_safe": triggered = c.kept_then_safe
	evidence = "%s:%d" % [badge.condition, count]
	if triggered:
		match badge.effect:
			"add_base": base += int(badge.value)
			"add_base_per": base += mini(int(badge.get("cap", MAX_SCORE)), count * int(badge.value))
			"add_multiplier": add += int(badge.value)
			"add_multiplier_per": add += count * int(badge.value)
			"add_base_and_multiplier_per": base += count * int(badge.value); add += count * int(badge.secondary)
			"multiply_multiplier": percent = int(round(float(percent) * float(badge.value) / 100.0))
			"grow_add_multiplier": add += int(growth.get(badge.id, 0))
	return {"triggered": triggered, "evidence": evidence, "base_add": base, "multiplier_add": add, "multiplier_percent": percent, "growth_delta": 1 if triggered and badge.effect == "grow_add_multiplier" else 0}

static func _step(id: String, triggered: bool, evidence: String, base: int, add: int, percent: int) -> Dictionary:
	return {"badge_id": id, "triggered": triggered, "evidence": evidence, "base_add": base, "multiplier_add": add, "multiplier_percent": percent, "growth_delta": 0}
