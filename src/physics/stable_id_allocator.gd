class_name StableIdAllocator
extends RefCounted

var _next_value: int


func _init(first_id: int = 1) -> void:
	_next_value = first_id


func next_id() -> int:
	var value := _next_value
	_next_value += 1
	return value
