# 《五球满贯》Steam 项目状态

更新时间：2026-08-17  
当前阶段：M2 PLANNING
主里程碑：M2 单机核心闭环
里程碑状态：PLANNING / GATE P REVIEW

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

## M2 规划状态

- OpenSpec Change `single-player-core-loop` 已创建并完成 proposal/specs/design/tasks；
- 严格校验通过，规划提交为 `1070630`，已推送 `origin/main`；
- 范围覆盖碰撞收球、三态、五球槽、复制/染色槽位同步、最佳组合、结算/保留、六球爆仓及单桌教程胜负；
- 明确 CUT 补球/道具、徽章/奖励、24 桌 Run、存档、Steamworks、PvP 与正式内容生产；
- 当前停在 Gate P，尚未创建 feature 分支或编写 M2 实现代码。

## 下一决策

1. 用户审核 `openspec/changes/single-player-core-loop/`；
2. 若 Gate P 批准，从提交 `1070630` 创建 `feature/single-player-core-loop` 并按 tasks 执行；
3. 若组合倍率、爆仓时序或教程桌范围需要修改，先更新 Change 并重新严格校验，不得直接编码。
