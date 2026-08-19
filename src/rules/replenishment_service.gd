class_name ReplenishmentService
extends RefCounted

const COLORS := ["red","blue","yellow","green"]
const POINTS := [Vector2(300,150),Vector2(430,150),Vector2(560,150),Vector2(690,150),Vector2(820,150),Vector2(300,480),Vector2(430,480),Vector2(560,480),Vector2(690,480),Vector2(820,480),Vector2(500,315),Vector2(780,315)]
const MIN_DISTANCE := 42.0
const WASTE_LIMIT := 10

static func replenish(state: CoreLoopSnapshot, target: int, seed: int, counter: int = 0) -> Dictionary:
	var current := 0
	for ball: BallState in state.table.balls:
		if ball.kind=="number" and state.collection_state(ball.id)=="uncollected": current+=1
	var needed := maxi(0,target-current)
	if needed==0: return {"ok":true,"spawned":[],"counter":counter}
	var next_id := 1
	for ball: BallState in state.table.balls: next_id=maxi(next_id,ball.id+1)
	var spawned: Array[Dictionary]=[]
	var cursor := _derived(seed,counter)%POINTS.size()
	for index in needed:
		var found := false
		for attempt in POINTS.size():
			var point: Vector2=POINTS[(cursor+attempt)%POINTS.size()]
			if _legal(state.table,point):
				var number: int = 1+(_derived(seed,counter+index*2+1)%9)
				var color: String = str(COLORS[_derived(seed,counter+index*2+2)%COLORS.size()])
				var ball: BallState = BallState.new(next_id,"number",number,color,point)
				state.table.balls.append(ball); state.collection_states[next_id]="uncollected"
				spawned.append(ball.to_dict()); next_id+=1; cursor=(cursor+attempt+1)%POINTS.size(); found=true; break
		if not found: return {"ok":false,"code":"replenishment_blocked","spawned":spawned,"counter":counter+spawned.size()*2}
	_ensure_basic_opportunity(state,spawned)
	return {"ok":true,"spawned":spawned,"counter":counter+needed*2}

static func cleanup_waste(state: CoreLoopSnapshot) -> Array[int]:
	var waste: Array[int]=[]
	for id in state.collection_states:
		if state.collection_state(int(id))=="waste": waste.append(int(id))
	waste.sort()
	var removed: Array[int]=[]
	while waste.size()>WASTE_LIMIT:
		var id: int = int(waste.pop_front()); removed.append(id); state.collection_states.erase(id)
		for index in range(state.table.balls.size()-1,-1,-1):
			if state.table.balls[index].id==id: state.table.balls.remove_at(index); break
	return removed

static func _legal(table: TableSnapshot, point: Vector2) -> bool:
	if point.distance_to(Vector2(130,315))<80: return false
	for ball: BallState in table.balls:
		if ball.position.distance_to(point)<MIN_DISTANCE: return false
	for wall: WallState in table.walls:
		if wall.rect.grow(22).has_point(point): return false
	return table.bounds.grow(-22).has_point(point)

static func _ensure_basic_opportunity(state: CoreLoopSnapshot, spawned: Array[Dictionary]) -> void:
	if spawned.size()<2: return
	var ids: Array=[]
	for item in spawned: ids.append(int(item.id))
	var first: BallState = state.table.find_ball(ids[0]); var second: BallState = state.table.find_ball(ids[1])
	if first!=null and second!=null: second.number=first.number; spawned[1]=second.to_dict()

static func _derived(seed:int,counter:int)->int:
	return absi(int(("m3-replenish:%s:%s"%[seed,counter]).sha256_text().substr(0,8).hex_to_int()))
