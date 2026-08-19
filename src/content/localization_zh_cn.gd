class_name LocalizationZhCn
extends RefCounted

const FORBIDDEN_PROTOTYPE_LABELS := ["SETTLE", "KEEP", "BUST", "YOU WIN", "LOSS", "TARGET", "SCORE", "STROKES", "RESET SAME TABLE"]
const TEXT := {
	"game.title": "五球满贯",
	"screen.tutorial": "核心规则教学桌",
	"action.shoot": "出杆",
	"action.settle": "结算",
	"action.keep": "保留球组",
	"action.reset": "同局重置",
	"action.start_run": "开始巡回",
	"action.tutorial": "教程",
	"hud.target": "目标分",
	"hud.score": "当前分",
	"hud.strokes": "剩余杆数",
	"hud.hand": "球组",
	"hud.best": "最佳组合",
	"hud.power": "力度",
	"hud.phase": "阶段",
	"hud.wall.copy": "复制墙",
	"hud.wall.dye": "染色墙",
	"phase.aiming": "瞄准",
	"phase.simulating": "球体运动中",
	"phase.post_shot_decision": "杆后决策",
	"phase.won": "胜利",
	"phase.lost": "失败",
	"feedback.ready": "移动鼠标瞄准，出杆后选择结算或保留",
	"feedback.reset": "教学桌已重置，请组成一个组合",
	"feedback.shot": "球体运动中",
	"feedback.settled": "本手结算 +%d",
	"feedback.kept": "已保留球组，下一杆会承担爆仓风险",
	"feedback.win": "球桌达标，你赢了！",
	"feedback.loss": "杆数耗尽，再试一次",
	"feedback.bust": "爆仓！第六格使当前球组作废",
	"feedback.decide": "选择结算 +%d，或保留后再打一杆",
	"feedback.empty": "本杆没有收球，请重新瞄准",
	"feedback.rejected": "无法出杆：%s",
	"controls": "鼠标瞄准 · 点击/空格出杆 · S 结算 · K 保留 · Q 道具 · 1～5 力度 · Tab 辅助线 · R 重置",
	"assist.concise": "简洁",
	"assist.standard": "标准",
	"assist.full": "完整",
	"combo.none": "无组合",
	"combo.single": "单球",
	"combo.pair": "对子",
	"combo.three_of_a_kind": "三条",
	"combo.bomb": "炸弹",
	"combo.five_ball_grand_slam": "五球满贯",
	"combo.straight": "顺子",
	"combo.same_color": "同色",
	"combo.same_color_straight": "同色顺",
}

static func text(key: String, fallback: String = "") -> String:
	return str(TEXT.get(key, fallback if not fallback.is_empty() else key))

static func format(key: String, values: Array) -> String:
	return text(key) % values

static func combo_name(combo_id: String) -> String:
	return text("combo.%s" % combo_id, combo_id)

static func phase_name(phase_id: String) -> String:
	return text("phase.%s" % phase_id, phase_id)

static func audit(required_keys: Array[String]) -> Dictionary:
	var missing: Array[String] = []
	for key in required_keys:
		if not TEXT.has(key) or str(TEXT[key]).strip_edges().is_empty():
			missing.append(key)
	return {"ok": missing.is_empty(), "missing": missing}
