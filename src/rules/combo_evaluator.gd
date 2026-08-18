class_name ComboEvaluator
extends RefCounted

const RULES_VERSION := "m2-combo-1"
const FIXED_MULTIPLIERS := {
	"single": 1, "pair": 3, "three_of_a_kind": 7,
	"bomb": 15, "five_ball_grand_slam": 30,
}
const LENGTH_MULTIPLIERS := {
	"straight": {3: 5, 4: 7, 5: 10},
	"same_color": {3: 5, 4: 7, 5: 10},
	"same_color_straight": {3: 12, 4: 18, 5: 25},
}


static func evaluate(slots: Array[HandSlot]) -> Dictionary:
	if slots.is_empty():
		return _empty_result()
	var candidates: Array[Dictionary] = []
	for mask in range(1, 1 << slots.size()):
		var indices: Array[int] = []
		for index in slots.size():
			if mask & (1 << index):
				indices.append(index)
		var candidate := _candidate_for(slots, indices)
		if not candidate.is_empty():
			candidates.append(candidate)
	candidates.sort_custom(_candidate_before)
	var best: Dictionary = candidates[0]
	var pollution: Array[int] = []
	for index in slots.size():
		if not best.participant_indices.has(index):
			pollution.append(index)
	best["pollution_indices"] = pollution
	best["rules_version"] = RULES_VERSION
	return best


static func _candidate_for(slots: Array[HandSlot], indices: Array[int]) -> Dictionary:
	var numbers: Array[int] = []
	var colors: Array[String] = []
	for index in indices:
		numbers.append(slots[index].number)
		colors.append(slots[index].color_id)
	var length := indices.size()
	var same_number := numbers.all(func(value: int) -> bool: return value == numbers[0])
	var same_color := colors.all(func(value: String) -> bool: return value == colors[0])
	var unique_numbers := numbers.duplicate()
	unique_numbers.sort()
	var straight := length >= 3
	if straight:
		for index in range(1, unique_numbers.size()):
			if unique_numbers[index] != unique_numbers[index - 1] + 1:
				straight = false
				break
	var type := ""
	var multiplier := 0
	if same_number:
		type = ["", "single", "pair", "three_of_a_kind", "bomb", "five_ball_grand_slam"][length]
		multiplier = FIXED_MULTIPLIERS[type]
	elif straight and same_color:
		type = "same_color_straight"
		multiplier = LENGTH_MULTIPLIERS[type][length]
	elif straight:
		type = "straight"
		multiplier = LENGTH_MULTIPLIERS[type][length]
	elif same_color and length >= 3:
		type = "same_color"
		multiplier = LENGTH_MULTIPLIERS[type][length]
	elif length == 1:
		type = "single"
		multiplier = 1
	else:
		return {}
	var number_sum: int = numbers.reduce(func(total: int, value: int) -> int: return total + value, 0)
	return {
		"type": type,
		"multiplier": multiplier,
		"participant_indices": indices.duplicate(),
		"number_sum": number_sum,
		"score": number_sum * multiplier,
	}


static func _candidate_before(left: Dictionary, right: Dictionary) -> bool:
	if left.score != right.score:
		return left.score > right.score
	if left.multiplier != right.multiplier:
		return left.multiplier > right.multiplier
	if left.participant_indices.size() != right.participant_indices.size():
		return left.participant_indices.size() > right.participant_indices.size()
	var left_indices: Array = left.participant_indices
	var right_indices: Array = right.participant_indices
	for index in left_indices.size():
		if left_indices[index] != right_indices[index]:
			return left_indices[index] < right_indices[index]
	return false


static func _empty_result() -> Dictionary:
	return {
		"type": "none", "multiplier": 0, "participant_indices": [],
		"pollution_indices": [], "number_sum": 0, "score": 0,
		"rules_version": RULES_VERSION,
	}
