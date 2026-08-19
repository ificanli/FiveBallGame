class_name RunSnapshot
extends RefCounted

const SCHEMA_VERSION := 1
const RULES_VERSION := "m3-run-1"
const VALID_PHASES := ["reward", "playing", "won", "lost", "abandoned"]

var seed := 0
var phase := "reward"
var table_index := -1
var reward_index := 0
var reward_choices: Array[String] = []
var badges: Array[String] = []
var badge_growth: Dictionary = {}
var tools: Dictionary = {"table_reset":1}
var active_protection := ""
var current_table: CoreLoopSnapshot
var table_results: Array[Dictionary] = []
var statistics: Dictionary = {"settles":0,"keeps":0,"busts":0,"tools_used":0,"badge_triggers":0}

static func create(run_seed: int) -> RunSnapshot:
	var run := RunSnapshot.new()
	run.seed = run_seed
	run.reward_choices.assign(RunContent.reward_choices(run_seed, 0, []))
	return run

func duplicate_state() -> RunSnapshot:
	return from_dict(to_dict())

func validate() -> Dictionary:
	if not VALID_PHASES.has(phase): return {"ok":false,"code":"invalid_phase"}
	if badges.size() > BadgeCatalog.MAX_EQUIPPED: return {"ok":false,"code":"badge_capacity"}
	if reward_choices.size() > 3: return {"ok":false,"code":"reward_capacity"}
	var seen := {}
	for id in badges:
		if BadgeCatalog.get_badge(id).is_empty(): return {"ok":false,"code":"unknown_badge"}
		if seen.has(id): return {"ok":false,"code":"duplicate_badge"}
		seen[id] = true
	var count := 0
	for id in tools:
		if ToolCatalog.get_tool(str(id)).is_empty() or int(tools[id]) < 0: return {"ok":false,"code":"invalid_tool"}
		count += int(tools[id])
	if count > ToolCatalog.MAX_CARRIED: return {"ok":false,"code":"tool_capacity"}
	if current_table != null and not current_table.validate().ok: return {"ok":false,"code":"invalid_table"}
	return {"ok":true}

func state_hash() -> String:
	return CanonicalState.hash_value(to_dict())

func to_dict() -> Dictionary:
	return {
		"schema_version":SCHEMA_VERSION,"rules_version":RULES_VERSION,"content_version":RunContent.VERSION,
		"seed":seed,"phase":phase,"table_index":table_index,"reward_index":reward_index,
		"reward_choices":reward_choices.duplicate(),"badges":badges.duplicate(),"badge_growth":badge_growth.duplicate(true),
		"tools":tools.duplicate(true),"active_protection":active_protection,
		"current_table":current_table.to_dict() if current_table != null else null,
		"table_results":table_results.duplicate(true),"statistics":statistics.duplicate(true),
	}

static func from_dict(data: Dictionary) -> RunSnapshot:
	var run := RunSnapshot.new()
	run.seed=int(data.get("seed",0)); run.phase=str(data.get("phase","reward")); run.table_index=int(data.get("table_index",-1)); run.reward_index=int(data.get("reward_index",0))
	run.reward_choices.assign(data.get("reward_choices",[])); run.badges.assign(data.get("badges",[])); run.badge_growth=data.get("badge_growth",{}).duplicate(true); run.tools=data.get("tools",{}).duplicate(true); run.active_protection=str(data.get("active_protection",""))
	var table_data: Variant=data.get("current_table"); run.current_table=CoreLoopSnapshot.from_dict(table_data) if table_data is Dictionary else null
	run.table_results.assign(data.get("table_results",[])); run.statistics=data.get("statistics",{}).duplicate(true)
	return run
