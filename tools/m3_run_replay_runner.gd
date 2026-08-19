extends SceneTree

func _init()->void:
	var args:=OS.get_cmdline_user_args(); var repeats:=100
	for i in args.size():
		if args[i]=="--repeat" and i+1<args.size(): repeats=int(args[i+1])
	var outputs:Array[Dictionary]=[]
	for seed in [31001,31002,31003]:
		var baseline:=_scripted_run(seed)
		for iteration in repeats:
			var repeated:=_scripted_run(seed)
			if repeated.hash!=baseline.hash:
				print(JSON.stringify({"status":"drift","seed":seed,"iteration":iteration})); quit(1); return
		outputs.append(baseline)
	print(JSON.stringify({"status":"success","schema_version":1,"repeat":repeats,"runs":outputs})); quit(0)

func _scripted_run(seed:int)->Dictionary:
	var run:=RunSnapshot.create(seed); var controller:=RunController.new(run)
	controller.choose_reward(run.reward_choices[seed%3])
	for table_index in 3:
		var table:=run.current_table
		# Deterministic rules-only settlement fixture; physical routes remain covered by M1/M2 replay.
		var ball:=table.table.balls[1]
		table.collection_states[ball.id]="hand"; table.hand.append(HandSlot.physical(ball)); table.refresh_combo(); table.phase="post_shot_decision"; table.target_score=1
		controller.settle({"power_level":1+table_index*2,"rail_hits":table_index,"copy_count":1 if table_index==2 else 0,"wall_kinds":["copy"] if table_index==2 else []})
		if run.phase=="reward": controller.choose_reward(run.reward_choices[0])
	return {"seed":seed,"phase":run.phase,"tables":run.table_results.size(),"badges":run.badges.duplicate(),"hash":run.state_hash()}
