# 《五球满贯》Steam 项目状态

更新时间：2026-08-17  
当前阶段：PREPRODUCTION / TOOLING  
主里程碑：M1 确定性物理技术桌  
里程碑状态：BUILDING

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

## 当前进行中 / 阻塞

- OpenSpec Change `deterministic-physics-table` 已于 2026-08-17 通过用户 Gate P；
- feature 分支、批准基线、网页原型 10 条对照清单、版本化回放契约与纯数据模型已完成；
- 当前 OpenSpec 进度：15/44 tasks；GdUnit4 31/31 通过；
- 固定步长、动态子步、摩擦/停止、圆—圆与圆—库边碰撞完成；700 次最大力度密集压力运行无漂移/非有限/残留重叠；
- Linux 导出包已生成但未在 Linux 桌面手动启动；不阻塞 M0，后续由跨平台 CI smoke 补强。

## 当前证据

- `reports/m0-local-verification.log`：4.7.1、导入、启动与 Golden contract；
- `reports/gdunit.log`：2 cases / 0 failures；
- `reports/export-retry.log`：Windows/Linux export exit 0；
- `reports/m0-final-checks.log`：Windows build startup、OpenSpec doctor、LFS 与敏感文件审计；
- `production/M0_ACCEPTANCE_REPORT.md`：完整验收摘要；
- `production/M0_INDEPENDENT_REVIEW.md`：基于远端干净 clone 的独立复验，结论 `PASS_ENGINEERING`。

## 下一决策

1. 实现激活因果、复制墙和染色墙；
2. 实现五档输入完整契约与同源预测；
3. 建立 Golden Replay 运行器、15～20 条案例和跨平台回归。
