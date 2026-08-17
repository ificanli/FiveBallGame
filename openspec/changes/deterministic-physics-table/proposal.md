## Why

《五球满贯》的正式版需要先证明 Godot 重构能够提供可学习、可复现、预测与实机一致的击球基础；否则后续收球、组合、构筑和 PvP 都会建立在不可信的物理结果上。M0 工具链已经通过，现在应以一张受控技术桌验证最小物理纵切，而不是提前生产正式内容。

## What Changes

- 新增与 Godot 节点解耦的固定步长 2D 圆形物理模拟能力。
- 新增母球与 6 颗数字球的固定 Seed 技术桌，以及五档离散力度输入。
- 新增圆—圆、圆—库边碰撞、能量损耗、摩擦、低速停止和单杆超时收尾规则。
- 新增简洁、标准、完整三档辅助线；预测与正式运动必须调用同一个模拟器。
- 新增复制墙与染色墙的最小技术验证，并保证只处理实际撞墙的激活数字球。
- 将 M0 Golden Replay 数据契约升级为可执行回放，覆盖固定初态、输入、事件、最终状态、tick 数与状态 Hash。
- 建立 Windows/Linux 确定性回归、100 次重复运行和预测首碰一致性验证。
- 建立与只读网页原型的固定场景手感对照清单和真人验收门。
- 不实现组合计分、结算/保留、六球爆仓、Run、徽章、道具、PvP、Steamworks 或联网。

## Capabilities

### New Capabilities

- `deterministic-physics-simulation`: 固定步长球体运动、碰撞、摩擦、停止、事件与可复现状态结果。
- `shot-input-and-trajectory-preview`: 五档力度、瞄准输入及与正式模拟同源的三档轨迹预测。
- `physics-table-wall-effects`: 技术桌中的激活传递、复制墙和染色墙最小规则及可观察事件。
- `golden-replay-regression`: Seed 化初态、出杆输入、回放结果、状态 Hash 和跨平台回归契约。

### Modified Capabilities

- 无。当前 `openspec/specs/` 尚无已发布能力规格。

## Impact

- 主要新增范围：`src/physics/`、最小必要的 `src/rules/`、`scenes/`、`data/`、`tests/`、`tools/`。
- CI 将增加确定性重复运行、Golden Replay 和 Windows/Linux 结果校验。
- Godot 4.7.1、GdUnit4 v6.2.0、OpenSpec 1.9.0 继续锁定，不引入新的运行时依赖。
- 网页原型 `E:/NewGame-prototypes/ricochet` 只读，用于行为与手感参考，不复制其正式 UI 或继续在 HTML 工程上开发。
- 这是首个会定义物理版本和回放兼容边界的变更；后续修改相关行为必须更新规格与 Golden Replay。
