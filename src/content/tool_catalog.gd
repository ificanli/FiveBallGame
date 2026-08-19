class_name ToolCatalog
extends RefCounted

const VERSION := "m3-tools-1"
const MAX_CARRIED := 3
const TOOLS := [
	{"id":"soft_pocket","name":"软袋","phase":"aiming","target":"none"},
	{"id":"insurance_slot","name":"保险球槽","phase":"aiming","target":"none"},
	{"id":"color_chalk","name":"调色粉笔","phase":"stopped","target":"physical_hand_ball"},
	{"id":"number_sticker","name":"数字贴纸","phase":"stopped","target":"physical_hand_ball"},
	{"id":"return_hook","name":"退球钩","phase":"stopped","target":"physical_hand_ball"},
	{"id":"table_reset","name":"清台重开","phase":"post_shot_decision","target":"none"},
]

static func get_tool(id: String) -> Dictionary:
	for tool: Dictionary in TOOLS:
		if tool.id == id: return tool.duplicate(true)
	return {}

static func audit() -> Dictionary:
	var errors: Array[String] = []
	var ids := {}
	for tool: Dictionary in TOOLS:
		var id := str(tool.get("id", ""))
		if id.is_empty() or ids.has(id): errors.append("duplicate_or_empty:%s" % id)
		ids[id] = true
		if str(tool.get("name", "")).is_empty(): errors.append("missing_name:%s" % id)
		if str(tool.get("phase", "")).is_empty(): errors.append("missing_phase:%s" % id)
	if TOOLS.size() != 6: errors.append("catalog_count")
	return {"ok": errors.is_empty(), "errors": errors}
