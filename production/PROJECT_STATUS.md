# 《五球满贯》Steam 项目状态

更新时间：2026-08-18
当前阶段：M2 HUMAN QA
主里程碑：M2 单机核心闭环
里程碑状态：HUMAN_QA

上一里程碑：M0 工具链与正式仓库 — `PASSED`

## 已完成

- 正式仓库与目录建立；Git main 分支、Git LFS 本地 hooks/属性生效；
- Godot 4.7.1 stable (`a13da4feb`) 单一版本安装并锁定；
- 最小 Godot 工程可导入、无头启动；
- OpenSpec 1.9.0 初始化，doctor 通过，遥测关闭；
- GdUnit4 v6.2.0 vendored，Headless 示例 2/2 通过；
- Golden Replay M0 数据契约与占位案例可加载并输出结构化 JSON，未执行物理；
- Windows/Linux 空工程本地导出成功；Windows 导出包 Headless 冒烟通过；
- GitHub Actions CI 已配置并在 run `32018118216` 成功完成验证与双平台导出工作流；
- 权威规划与历史资料已复制并记录来源；
- 未开发正式物理、内容、Steamworks、联网或 MCP。

## 当前结论

- OpenSpec Change `deterministic-physics-table` 已于 2026-08-17 通过用户 Gate P，并于 2026-08-18 获真人验收通过；
- feature 分支、批准基线、网页原型 10 条对照清单、版本化回放契约与纯数据模型已完成；
- OpenSpec 进度：44/44 tasks；GdUnit4 51/51 通过；
- 固定 Seed 技术桌、规则快照表现适配、鼠标瞄准、五档力度、三档辅助、同 Seed 重置、调试覆盖与墙体反馈已接入；
- 五档输入和简洁/标准/完整同源预测完成；Headless 无缓存平均约 5.95/17.49/39.30 ms；
- 固定步长、动态子步、摩擦/停止、圆—圆与圆—库边碰撞完成；700 次最大力度密集压力运行无漂移/非有限/残留重叠；
- Linux 导出包已生成但未在 Linux 桌面手动启动；不阻塞 M0，后续由跨平台 CI smoke 补强。

## 当前证据

- `reports/m0-local-verification.log`：4.7.1、导入、启动与 Golden contract；
- `reports/gdunit.log`：2 cases / 0 failures；
- `reports/export-retry.log`：Windows/Linux export exit 0；
- `reports/m0-final-checks.log`：Windows build startup、OpenSpec doctor、LFS 与敏感文件审计；
- `production/M0_ACCEPTANCE_REPORT.md`：完整验收摘要；
- `production/M0_INDEPENDENT_REVIEW.md`：基于远端干净 clone 的独立复验，结论 `PASS_ENGINEERING`。

## M2 当前状态

- Gate P 已批准；当前分支 `feature/single-player-core-loop`，批准回退点 `7d17737`；
- 已实现碰撞收球、三态、五球槽、复制/染色槽位同步、唯一最佳组合、基础得分、结算/保留、六球爆仓、有限杆数、胜负与同配置重置；
- 固定 Seed 教程桌已接入五档力度与三档辅助线；Windows 候选位于 `builds/windows/FiveBallGrandSlam.exe`；
- GdUnit4 71/71；M2 8 类多杆回放 ×100；500 次压力会话；OpenSpec 严格校验全部通过；
- 远端干净 clone 已完成 71/71、回放、Windows/Linux 导出和 Windows 候选启动；
- CUT 系统未实现：补球/道具、徽章/奖励、24 桌 Run、存档、Steamworks、PvP、正式内容生产；
- 远端 CI run `32184599980` 已触发，但匿名 API 限流导致最终结论尚待再次确认，不据此宣称通过；
- 当前 OpenSpec 进度 37/41，剩余真人 15 分钟验收、问题修复/确认、状态交付与最终停门。

## 下一决策

1. 真人从 Windows 导出包连续试玩至少 15 分钟，并按 `production/M2_HUMAN_QA_CHECKLIST.md` 覆盖结算、保留、功能墙、爆仓、终态和重置；
2. 若有阻塞或规则不符，回到 feature 分支修复并补回归；
3. 真人通过且远端 CI 结论确认后，完成 Gate I 收尾；未获最终批准不得同步归档或合并 `main`。
