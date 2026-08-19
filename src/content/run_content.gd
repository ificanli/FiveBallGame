class_name RunContent
extends RefCounted

const VERSION := "m3-run-content-1"
const TABLES := [
	{"id":"qualification","name":"资格桌","target":220,"strokes":5,"uncollected_target":6,"layout":0},
	{"id":"high_stakes","name":"高额桌","target":520,"strokes":6,"uncollected_target":8,"layout":1},
	{"id":"dealer","name":"庄家桌","target":900,"strokes":7,"uncollected_target":10,"layout":2},
]
const OPENING_STARTERS := ["twin_ring","rail_guest","copy_tax"]

static func table_config(index: int) -> Dictionary:
	return TABLES[index].duplicate(true) if index >= 0 and index < TABLES.size() else {}

static func create_table(run_seed: int, index: int) -> CoreLoopSnapshot:
	var config := table_config(index)
	var table_seed := _derived_int(run_seed, "table", index)
	var table := TableSnapshot.create_seeded_technical_table(table_seed)
	table.content_version = "%s-%s" % [VERSION, config.id]
	if index == 1:
		table.balls.append(BallState.new(8, "number", 2 + table_seed % 7, "yellow", Vector2(560, 440)))
	elif index == 2:
		table.balls.append(BallState.new(8, "number", 2 + table_seed % 7, "blue", Vector2(560, 440)))
		table.balls.append(BallState.new(9, "number", 1 + (table_seed / 7) % 9, "green", Vector2(760, 500)))
	return CoreLoopSnapshot.create(table, int(config.target), int(config.strokes))

static func reward_choices(run_seed: int, reward_index: int, equipped: Array[String]) -> Array[String]:
	if reward_index == 0:
		return OPENING_STARTERS.duplicate()
	var preferred_build := ""
	if not equipped.is_empty():
		preferred_build = str(BadgeCatalog.get_badge(equipped[0]).get("build", ""))
	var pool: Array[String] = []
	for badge: Dictionary in BadgeCatalog.BADGES:
		if not equipped.has(badge.id) and badge.role != "starter": pool.append(badge.id)
	pool.sort()
	var choices: Array[String] = []
	var preferred := BadgeCatalog.ids_for_build(preferred_build)
	for id in preferred:
		if pool.has(id) and not choices.has(id): choices.append(id); break
	var cursor := _derived_int(run_seed, "reward", reward_index) % maxi(1, pool.size())
	while choices.size() < 3 and not pool.is_empty():
		var id := pool[cursor % pool.size()]
		if not choices.has(id): choices.append(id)
		cursor += 1
	return choices

static func _derived_int(seed: int, stream: String, counter: int) -> int:
	var digest := "%s:%s:%s:%s" % [VERSION, seed, stream, counter]
	return absi(int(digest.sha256_text().substr(0, 8).hex_to_int()))
