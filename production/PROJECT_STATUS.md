# 《五球满贯》Steam 项目状态

更新时间：2026-08-19
当前阶段：M3 Gate P 规划审核
主里程碑：M3 构筑 MVP
里程碑状态：PLANNING / NOT APPROVED FOR IMPLEMENTATION

## 已通过里程碑

- M0 工具链与正式仓库：`PASSED`
- M1 确定性物理技术桌：`PASSED`
- M2 单机核心闭环：`PASSED`

## M2 结论

- 用户已批准 `single-player-core-loop` Gate P，并在导出候选版本试玩后明确回复：`算了，这个版本通过。开始下个版本，下个版本改成中文吧`。
- 已实现碰撞收球、未收/本手/废球三态、五球槽、复制/染色槽位同步、唯一最佳组合、基础得分、结算/保留、六球爆仓、有限杆数、胜负及同配置重置。
- 固定 Seed 教程桌复用 M1 五档力度、三档辅助、确定性模拟与表现适配。
- GdUnit4：71/71；M2 多杆规则回放：8 类 ×100，零漂移；压力：500 个 Seed 会话通过。
- 远端干净 clone 已完成 71/71、规则回放、Windows/Linux 导出及 Windows 候选启动。
- OpenSpec `single-player-core-loop`：4/4 artifacts，严格校验通过，任务 41/41。
- 真人结论记录：`production/M2_HUMAN_QA_RESULT.md`。用户没有逐项给出时长或清单答案，因此不虚构逐项记录。

## 已知问题与证据边界

- M2 玩家可见 UI 仍含英文。用户接受本版本，但明确要求下个版本改中文；M3 必须把简体中文玩家界面列为硬性规格和验收项。
- GitHub Actions 历史 run `32184599980` 为失败，不再误报为待确认。
- CI 修复后 run `32207178927` 的 Linux 全验证已成功；Windows 在执行完整 18 案例 ×100 物理回放时超过一小时仍在运行。完整本地 Windows 回放和干净 clone Windows 证据已通过；云端 Windows 长耗时列为工程 follow-up，不宣称该 run 全绿，也不通过降低重复次数伪造绿灯。
- 自动测试证明稳定性与确定性，不证明构筑玩法好玩。

## M3 当前状态

独立 OpenSpec Change `buildcraft-mvp` 已完成 proposal/spec/design/tasks，OpenSpec 4/4 且 strict validation 通过；当前停在 Gate P，尚未实现任何 M3 规则。范围基线：

- 锁定 18 枚徽章，分为纯净组合、撞库连锁、功能墙冒险三套肉眼可区分且会改变球路判断的打法；
- 6 种道具；
- 3 张正式规则球桌；
- 奖励三选一；
- 15～25 分钟 Run；
- Run 结算与简单统计；
- 默认玩家可见界面全部使用简体中文，内部 ID/回放字段继续保持稳定英文键。

规划位置：`openspec/changes/buildcraft-mvp/`。未获 M3 Gate P 明确批准前，不实现徽章、道具、奖励或 Run。
