class_name BadgeCatalog
extends RefCounted

const VERSION := "m3-badges-1"
const MAX_EQUIPPED := 5
const BADGES := [
	{"id":"twin_ring","name":"双生环","build":"pure_combo","role":"starter","condition":"combo_pair","effect":"add_multiplier","value":4,"decision":true},
	{"id":"straight_compass","name":"顺行仪","build":"pure_combo","role":"amplifier","condition":"straight_4_plus","effect":"multiply_multiplier","value":150,"decision":true},
	{"id":"pure_color_lamp","name":"纯色灯","build":"pure_combo","role":"starter","condition":"same_color_participant","effect":"add_multiplier_per","value":1,"decision":true},
	{"id":"perfect_hand","name":"完美球组","build":"pure_combo","role":"core","condition":"no_pollution","effect":"multiply_multiplier","value":150,"decision":true},
	{"id":"pattern_upgrader","name":"牌型升级器","build":"pure_combo","role":"finisher","condition":"matching_three_plus","effect":"multiply_multiplier","value":150,"decision":true},
	{"id":"color_straight_prize","name":"纯色顺大奖","build":"pure_combo","role":"growth","condition":"same_color_straight","effect":"grow_add_multiplier","value":1,"decision":true},
	{"id":"rail_guest","name":"贴库客","build":"rail_chain","role":"starter","condition":"rail_hits","effect":"add_base_per","value":3,"cap":18,"decision":true},
	{"id":"fifth_gear","name":"第五档","build":"rail_chain","role":"amplifier","condition":"power_five_three_slots","effect":"multiply_multiplier","value":200,"decision":true},
	{"id":"soft_touch_master","name":"轻推大师","build":"rail_chain","role":"core","condition":"power_one_two_slots","effect":"add_base","value":35,"decision":true},
	{"id":"chain_reaction","name":"连锁反应","build":"rail_chain","role":"core","condition":"indirect_participants","effect":"add_multiplier_per","value":2,"decision":true},
	{"id":"rebound_expert","name":"反弹专家","build":"rail_chain","role":"finisher","condition":"participant_after_rail","effect":"add_multiplier_per","value":2,"decision":true},
	{"id":"domino","name":"多米诺","build":"rail_chain","role":"growth","condition":"activation_depth","effect":"add_base_per","value":8,"decision":true},
	{"id":"copy_tax","name":"复印税","build":"wall_risk","role":"starter","condition":"copy_count","effect":"add_multiplier_per","value":2,"decision":true},
	{"id":"palette","name":"调色盘","build":"wall_risk","role":"starter","condition":"dyed_participants","effect":"add_base_and_multiplier_per","value":6,"secondary":1,"decision":true},
	{"id":"double_charge_mirror","name":"双充能镜","build":"wall_risk","role":"core","condition":"always","effect":"copy_charge_bonus","value":1,"decision":true},
	{"id":"wall_circuit","name":"墙体回路","build":"wall_risk","role":"amplifier","condition":"two_wall_kinds","effect":"multiply_multiplier","value":150,"decision":true},
	{"id":"full_hand_bonus","name":"满仓红利","build":"wall_risk","role":"finisher","condition":"five_slots","effect":"multiply_multiplier","value":150,"decision":true},
	{"id":"greed_fund","name":"贪心基金","build":"wall_risk","role":"growth","condition":"kept_then_safe","effect":"grow_add_multiplier","value":1,"decision":true},
]

static func get_badge(id: String) -> Dictionary:
	for badge: Dictionary in BADGES:
		if badge.id == id:
			return badge.duplicate(true)
	return {}

static func ids_for_build(build_id: String) -> Array[String]:
	var ids: Array[String] = []
	for badge: Dictionary in BADGES:
		if badge.build == build_id:
			ids.append(badge.id)
	return ids

static func audit() -> Dictionary:
	var errors: Array[String] = []
	var ids := {}
	var role_by_build := {}
	var decision_count := 0
	for badge: Dictionary in BADGES:
		var id := str(badge.get("id", ""))
		if id.is_empty() or ids.has(id): errors.append("duplicate_or_empty:%s" % id)
		ids[id] = true
		if str(badge.get("name", "")).is_empty(): errors.append("missing_name:%s" % id)
		var build := str(badge.get("build", ""))
		if not role_by_build.has(build): role_by_build[build] = {}
		role_by_build[build][str(badge.get("role", ""))] = true
		if bool(badge.get("decision", false)): decision_count += 1
	for build in ["pure_combo", "rail_chain", "wall_risk"]:
		if ids_for_build(build).size() != 6: errors.append("build_count:%s" % build)
		var roles: Dictionary = role_by_build.get(build, {})
		if not roles.has("starter") or not roles.has("core") or not (roles.has("amplifier") or roles.has("finisher")):
			errors.append("role_coverage:%s" % build)
	if BADGES.size() != 18: errors.append("catalog_count")
	if decision_count < 13: errors.append("decision_count")
	return {"ok": errors.is_empty(), "errors": errors, "decision_count": decision_count}
