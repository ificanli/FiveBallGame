# 《五球满贯》Steam 项目状态

更新时间：2026-08-19
当前阶段：M3 HUMAN QA / CLOSED
主里程碑：M3 构筑 MVP
里程碑状态：PASSED

## 已通过里程碑

- M0 工具链与正式仓库：`PASSED`
- M1 确定性物理技术桌：`PASSED`
- M2 单机核心闭环：`PASSED`
- M3 构筑 MVP：`PASSED`

## M3 结论

`buildcraft-mvp` 已完成实现、自动化验证和产品负责人真人验收，Change 已归档到：

`openspec/changes/archive/2026-08-19-buildcraft-mvp/`

正式规格已同步到 `openspec/specs/`。

已交付：

- 18 枚徽章，三套 Build：纯净组合、撞库连锁、功能墙冒险；
- 6 种道具；
- 3 张规则球桌与 15～25 分钟 Run；
- 奖励三选一、确定性补球、Run 统计；
- 玩家可见 UI 已切换为简体中文，内部 ID/回放字段保持稳定英文键；
- Windows 导出启动、Linux 导出、本地平衡冒烟均通过；
- GdUnit4：86/86；M1 Golden 18×100；M2 回放 8 类×100；M3 Run 回放 100 次；
- 真人产品负责人确认：验收通过。

## 证据边界与遗留风险

- 自动平衡结论为 `AUTOMATED_BALANCE_PASS / HUMAN_VALIDATION_REQUIRED`，不代表游戏长期耐玩、市场成立或 PvP 成立；
- GitHub Windows runner 的完整回放/Artifact 传输仍不稳定；本地 Windows、Linux 云端和干净 clone 证据通过，未降低重复次数伪造 CI 绿灯；
- M3 默认玩家界面为中文，但字体覆盖和极端分辨率仍需要后续发布阶段继续补验；
- 尚未接入 Steamworks、联网、PvP、24 桌战役、存档和正式商业美术。

## 下一决策

1. `buildcraft-mvp` 已归档并准备合并到 `main`；
2. 不自动开始 M4；PvP 仍是独立产品假设，必须另建 OpenSpec Change；
3. 下一步可选择本地热座 PvP 黑盒或 M5 发布纵切，均需重新通过 Gate P。
