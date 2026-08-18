class_name CanonicalState
extends RefCounted

const GRID := 0.0001


static func normalize(value: Variant) -> Variant:
	match typeof(value):
		TYPE_DICTIONARY:
			var source: Dictionary = value
			var output := {}
			var keys := source.keys()
			keys.sort_custom(func(left: Variant, right: Variant) -> bool: return str(left) < str(right))
			for key: Variant in keys:
				output[str(key)] = normalize(source[key])
			return output
		TYPE_ARRAY:
			var output_array: Array = []
			for item: Variant in value:
				output_array.append(normalize(item))
			return output_array
		TYPE_INT:
			return float(value)
		TYPE_FLOAT:
			var number: float = value
			if not is_finite(number):
				return "__NON_FINITE__"
			return snapped(number, GRID)
		TYPE_VECTOR2:
			var vector: Vector2 = value
			return normalize({"x": vector.x, "y": vector.y})
		_:
			return value


static func canonical_json(value: Variant) -> String:
	return JSON.stringify(normalize(value), "", true, true)


static func hash_value(value: Variant) -> String:
	return canonical_json(value).sha256_text()


static func first_difference(left: Variant, right: Variant, path: String = "$") -> Dictionary:
	var normalized_left: Variant = normalize(left)
	var normalized_right: Variant = normalize(right)
	return _compare_normalized(normalized_left, normalized_right, path)


static func _compare_normalized(left: Variant, right: Variant, path: String) -> Dictionary:
	if typeof(left) != typeof(right):
		return {"equal": false, "path": path, "left": left, "right": right, "reason": "type"}
	if typeof(left) == TYPE_DICTIONARY:
		var left_dict: Dictionary = left
		var right_dict: Dictionary = right
		var all_keys := left_dict.keys()
		for key: Variant in right_dict.keys():
			if not all_keys.has(key):
				all_keys.append(key)
		all_keys.sort_custom(func(a: Variant, b: Variant) -> bool: return str(a) < str(b))
		for key: Variant in all_keys:
			var child_path := "%s.%s" % [path, str(key)]
			if not left_dict.has(key) or not right_dict.has(key):
				return {"equal": false, "path": child_path, "left": left_dict.get(key), "right": right_dict.get(key), "reason": "missing"}
			var difference := _compare_normalized(left_dict[key], right_dict[key], child_path)
			if not difference.equal:
				return difference
		return {"equal": true, "path": path}
	if typeof(left) == TYPE_ARRAY:
		var left_array: Array = left
		var right_array: Array = right
		if left_array.size() != right_array.size():
			return {"equal": false, "path": path, "left": left_array.size(), "right": right_array.size(), "reason": "length"}
		for index in left_array.size():
			var difference := _compare_normalized(left_array[index], right_array[index], "%s[%d]" % [path, index])
			if not difference.equal:
				return difference
		return {"equal": true, "path": path}
	if left != right:
		return {"equal": false, "path": path, "left": left, "right": right, "reason": "value"}
	return {"equal": true, "path": path}
