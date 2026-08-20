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
	"build.pure_combo": "纯净组合",
	"build.rail_chain": "撞库连锁",
	"build.wall_risk": "功能墙冒险",
	"role.starter": "启动器",
	"role.core": "核心件",
	"role.amplifier": "放大器",
	"role.finisher": "收尾件",
	"role.growth": "成长件",
	"badge.twin_ring.desc": "对子组合时，倍率 +4。",
	"badge.straight_compass.desc": "4 连及以上顺子时，倍率 ×1.5。",
	"badge.pure_color_lamp.desc": "参与组合的同色球，每颗倍率 +1。",
	"badge.perfect_hand.desc": "无污染球时，倍率 ×1.5。",
	"badge.pattern_upgrader.desc": "三条及以上组合时，倍率 ×1.5。",
	"badge.color_straight_prize.desc": "同色顺时成长，本 Run 永久倍率 +1。",
	"badge.rail_guest.desc": "每撞库一次，基础分 +3（上限 +18）。",
	"badge.fifth_gear.desc": "五档力度收满三槽时，倍率 ×1.5。",
	"badge.soft_touch_master.desc": "一、二档力度收球时，基础分 +35。",
	"badge.chain_reaction.desc": "间接激活的球，每颗倍率 +2。",
	"badge.rebound_expert.desc": "撞库后进球的球，每颗倍率 +2。",
	"badge.domino.desc": "激活链每深一层，基础分 +8。",
	"badge.copy_tax.desc": "每复制一次，倍率 +2。",
	"badge.palette.desc": "被染色的球，每颗基础分 +6、倍率 +1。",
	"badge.double_charge_mirror.desc": "复制墙每次充能 +1。",
	"badge.wall_circuit.desc": "同一杆触发复制与染色墙时，倍率 ×1.5。",
	"badge.full_hand_bonus.desc": "收满五槽时，倍率 ×1.5。",
	"badge.greed_fund.desc": "保留后安全结算时成长，本 Run 永久倍率 +1。",
	"tool.soft_pocket.desc": "出杆前使用：五槽满时，第六球转为废球，原五槽保留。",
	"tool.insurance_slot.desc": "出杆前使用：允许一次临时第六槽参与组合，随后强制结算。",
	"tool.color_chalk.desc": "球停后使用：选择一颗本手实体球，改变其颜色。",
	"tool.number_sticker.desc": "球停后使用：选择一颗本手实体球，数字 +1 或 -1（1～9）。",
	"tool.return_hook.desc": "球停后使用：把一颗本手实体球移出球槽，转为废球。",
	"tool.table_reset.desc": "杆后决策时使用：清空当前球组并重摆，保留分数与杆数。",
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
