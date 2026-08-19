class_name RunStatistics
extends RefCounted

const VERSION := 1

static func summary(run: RunSnapshot, end_reason: String) -> Dictionary:
	return {
		"schema_version": VERSION, "rules_version": RunSnapshot.RULES_VERSION,
		"content_version": RunContent.VERSION, "seed": run.seed, "end_reason": end_reason,
		"phase": run.phase, "tables": run.table_results.duplicate(true),
		"badges": run.badges.duplicate(), "badge_growth": run.badge_growth.duplicate(true),
		"tools_remaining": run.tools.duplicate(true), "statistics": run.statistics.duplicate(true),
	}

static func export_json(run: RunSnapshot, path: String, end_reason: String) -> Dictionary:
	if path.contains("..") or path.contains(":"):
		return {"ok":false,"code":"unsafe_path"}
	var absolute:=ProjectSettings.globalize_path("user://%s"%path)
	DirAccess.make_dir_recursive_absolute(absolute.get_base_dir())
	var file:=FileAccess.open(absolute,FileAccess.WRITE)
	if file==null:return {"ok":false,"code":"open_failed"}
	var payload:=summary(run,end_reason)
	file.store_string(JSON.stringify(payload,"  ",false,true)+"\n")
	return {"ok":true,"path":"user://%s"%path,"hash":CanonicalState.hash_value(payload)}
