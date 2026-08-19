class_name ToolService
extends RefCounted

static func use(run: RunSnapshot, tool_id: String, parameters: Dictionary = {}) -> Dictionary:
	if int(run.tools.get(tool_id,0))<=0: return _reject("tool_unavailable")
	if ToolCatalog.get_tool(tool_id).is_empty(): return _reject("unknown_tool")
	var table:=run.current_table
	if table==null or table.phase=="simulating": return _reject("tool_phase")
	match tool_id:
		"soft_pocket","insurance_slot":
			if table.phase!="aiming": return _reject("tool_phase")
			run.active_protection=tool_id
			table.active_bust_protection=tool_id
			table.hand_capacity=6 if tool_id=="insurance_slot" else 5
			table.protection_triggered=false
			table.forced_settle=false
		"color_chalk":
			var ball:=_physical_hand_ball(table,int(parameters.get("ball_id",0)))
			var color:=str(parameters.get("color_id",""))
			if ball==null or not ["red","blue","yellow","green"].has(color): return _reject("invalid_target")
			ball.color_id=color; table.find_physical_slot(ball.id).color_id=color; table.refresh_combo()
		"number_sticker":
			var ball:=_physical_hand_ball(table,int(parameters.get("ball_id",0))); var delta:=int(parameters.get("delta",0))
			if ball==null or not [-1,1].has(delta) or ball.number+delta<1 or ball.number+delta>9: return _reject("invalid_target")
			ball.number+=delta; table.find_physical_slot(ball.id).number=ball.number; table.refresh_combo()
		"return_hook":
			var ball:=_physical_hand_ball(table,int(parameters.get("ball_id",0)))
			if ball==null: return _reject("invalid_target")
			for index in range(table.hand.size()-1,-1,-1):
				if table.hand[index].has_physical_ball and table.hand[index].physical_ball_id==ball.id: table.hand.remove_at(index); break
			table.collection_states[ball.id]="waste"; table.refresh_combo()
		"table_reset":
			if table.phase!="post_shot_decision": return _reject("tool_phase")
			var fresh:=RunContent.create_table(run.seed,run.table_index)
			fresh.score=table.score; fresh.strokes_remaining=table.strokes_remaining; run.current_table=fresh
		_:
			return _reject("not_implemented")
	run.tools[tool_id]=int(run.tools[tool_id])-1
	if run.tools[tool_id]<=0: run.tools.erase(tool_id)
	run.statistics.tools_used=int(run.statistics.get("tools_used",0))+1
	return {"ok":true,"tool_id":tool_id,"run":run}

static func _physical_hand_ball(table:CoreLoopSnapshot,id:int)->BallState:
	var slot:=table.find_physical_slot(id)
	return table.table.find_ball(id) if slot!=null else null

static func _reject(code:String)->Dictionary:
	return {"ok":false,"code":code}
