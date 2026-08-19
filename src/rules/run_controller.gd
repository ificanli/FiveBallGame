class_name RunController
extends RefCounted

var state: RunSnapshot
var table_controller: CoreLoopController

func _init(initial:RunSnapshot=null)->void:
	state=initial
	if state!=null and state.current_table!=null: table_controller=CoreLoopController.new(state.current_table)

func choose_reward(badge_id:String,replace_index:int=-1)->Dictionary:
	if state.phase!="reward" or not state.reward_choices.has(badge_id): return _reject("reward_not_allowed")
	if state.badges.size()<BadgeCatalog.MAX_EQUIPPED: state.badges.append(badge_id)
	elif replace_index>=0 and replace_index<state.badges.size(): state.badges[replace_index]=badge_id
	else: return _reject("replacement_required")
	state.reward_choices.clear(); state.table_index+=1; state.current_table=RunContent.create_table(state.seed,state.table_index); state.phase="playing"; table_controller=CoreLoopController.new(state.current_table)
	return {"ok":true,"state":state}

func reorder_badges(from_index:int,to_index:int)->Dictionary:
	if state.phase=="playing" and state.current_table!=null and state.current_table.phase=="simulating": return _reject("reorder_not_allowed")
	if from_index<0 or to_index<0 or from_index>=state.badges.size() or to_index>=state.badges.size(): return _reject("invalid_index")
	var badge: String = str(state.badges.pop_at(from_index)); state.badges.insert(to_index,badge); return {"ok":true,"state":state}

func settle(evidence:Dictionary={})->Dictionary:
	if state.phase!="playing" or table_controller==null: return _reject("settle_not_allowed")
	var table: CoreLoopSnapshot = table_controller.state
	if table.phase!="post_shot_decision": return _reject("settle_not_allowed")
	var context: SettlementContext = SettlementContext.from_values(table.combo,evidence.merged({"hand_size":table.hand.size(),"final_stroke":table.strokes_remaining==0},true))
	var settlement: Dictionary = BadgeSettlementPipeline.evaluate(context,state.badges,state.badge_growth)
	table.combo.score=int(settlement.final_score)
	var result: Dictionary = table_controller.settle()
	if not result.ok:return result
	state.badge_growth.merge(settlement.growth_changes,true); state.statistics.settles=int(state.statistics.settles)+1
	for step:Dictionary in settlement.steps:
		if step.triggered: state.statistics.badge_triggers=int(state.statistics.badge_triggers)+1
	if table.phase=="won": _complete_table(settlement.final_score)
	elif table.phase!="lost": ReplenishmentService.replenish(table,int(RunContent.table_config(state.table_index).uncollected_target),state.seed,state.table_index*100+int(state.statistics.settles)); ReplenishmentService.cleanup_waste(table)
	return {"ok":true,"banked_score":settlement.final_score,"settlement":settlement,"state":state}

func keep()->Dictionary:
	var result: Dictionary = table_controller.keep() if table_controller!=null else _reject("keep_not_allowed")
	if result.ok: state.statistics.keeps=int(state.statistics.keeps)+1
	return result

func use_tool(id:String,parameters:Dictionary={})->Dictionary:
	var result: Dictionary = ToolService.use(state,id,parameters)
	if result.ok and state.current_table!=table_controller.state: table_controller=CoreLoopController.new(state.current_table)
	return result

func _complete_table(final_hand_score:int)->void:
	state.table_results.append({"table_id":RunContent.table_config(state.table_index).id,"score":state.current_table.score,"final_hand_score":final_hand_score,"strokes_left":state.current_table.strokes_remaining})
	if state.table_index>=RunContent.TABLES.size()-1: state.phase="won"
	else:
		state.phase="reward"; state.reward_index+=1; state.reward_choices=RunContent.reward_choices(state.seed,state.reward_index,state.badges); state.current_table=null; table_controller=null

func _reject(code:String)->Dictionary:return {"ok":false,"code":code,"state":state}
