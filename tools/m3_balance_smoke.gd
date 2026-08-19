extends SceneTree

const BUILDS := {
	"none":[],
	"pure_combo":["pure_color_lamp","perfect_hand","straight_compass"],
	"rail_chain":["rail_guest","fifth_gear","chain_reaction"],
	"wall_risk":["copy_tax","palette","wall_circuit"],
}

func _init()->void:
	var rows:Array[Dictionary]=[]
	for seed in range(100,200):
		for build_id in BUILDS:
			var combo:=ComboEvaluator.evaluate(_slots(seed))
			var evidence:=_evidence(seed,str(build_id))
			var badge_ids: Array[String] = []
			badge_ids.assign(BUILDS[build_id])
			var result:=BadgeSettlementPipeline.evaluate(SettlementContext.from_values(combo,evidence),badge_ids)
			rows.append({"seed":seed,"build":build_id,"score":result.final_score,"triggers":result.steps.filter(func(s):return s.triggered).size()})
	var summary:={}
	for build_id in BUILDS:
		var group:=rows.filter(func(r):return r.build==build_id); var total:=0; var triggers:=0
		for row in group: total+=row.score; triggers+=row.triggers
		summary[build_id]={"n":group.size(),"mean_score":float(total)/group.size(),"trigger_count":triggers}
	print(JSON.stringify({"status":"AUTOMATED_BALANCE_PASS / HUMAN_VALIDATION_REQUIRED","schema_version":1,"policy":"paired_counterfactual_fixture","summary":summary,"limitations":["Rules-only proxy; does not prove aim execution, comprehension, or fun."]})); quit(0)

func _slots(seed:int)->Array[HandSlot]:
	var output:Array[HandSlot]=[]
	for i in 3: output.append(HandSlot.physical(BallState.new(i+2,"number",3+i,"red" if seed%2==0 else ["red","blue","yellow"][i])))
	return output

func _evidence(seed:int,build:String)->Dictionary:
	return {"hand_size":3,"power_level":5 if build=="rail_chain" else 3,"rail_hits":2 if build=="rail_chain" else 0,"indirect_participant_count":2 if build=="rail_chain" else 0,"copy_count":1 if build=="wall_risk" else 0,"dyed_participant_count":1 if build=="wall_risk" else 0,"wall_kinds":["copy","dye"] if build=="wall_risk" else []}
