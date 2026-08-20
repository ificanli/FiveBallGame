# ui-interaction-completeness Specification

## Purpose
M3.5 用 Godot Control 节点替换手绘 HUD，补齐主菜单、暂停、奖励、道具、徽章、结算、统计与教程的完整中文交互闭环，同时保持规则真相与回放确定性不变。

## ADDED Requirements

### Requirement: Player-facing interaction uses node UI, not hand-drawn overlays
玩家界面 SHALL 使用 Godot Control 节点（Button、Panel、ScrollContainer、Label、OptionButton 等）承载菜单、面板、卡片、按钮与说明文字；球桌内容（球、墙壁、库边、辅助线、轨迹预览）允许保留在 `_draw()`，但按钮、文字、卡片与菜单 SHALL NOT 通过手绘文本模拟点击。

#### Scenario: A menu action is clickable
- **WHEN** 玩家在主菜单、暂停、奖励、道具、徽章、结算或统计界面点击一个操作
- **THEN** 该操作 SHALL 由可聚焦的节点响应，而非 `_draw()` 文本的鼠标命中检测

### Requirement: Commands are the only mutation path
UI 节点 SHALL NOT 直接修改规则状态；所有玩家操作 SHALL 映射为既有命令（瞄准、出杆、结算、保留、装备/替换徽章、使用道具、重开、开始 Run）。

#### Scenario: UI and headless execute the same sequence
- **WHEN** 相同命令序列分别通过 UI 与 Headless 执行
- **THEN** 规则回放与 Run 状态 Hash SHALL 完全一致

### Requirement: Menus and flows are complete and keyboard-mouse equivalent
玩家 SHALL 能只靠鼠标或只靠键盘完成：开始巡回、进入教程、暂停/继续/重开/回主菜单、奖励三选一、选择与取消道具、替换/排序徽章、结算、保留、爆仓处理、查看 Run 结算统计。

#### Scenario: Player reaches every required interaction
- **WHEN** 玩家从主菜单开始并走完一整局 Run
- **THEN** 所有必要操作 SHALL 同时具备鼠标与键盘入口，且键盘入口有可见提示

### Requirement: Decision panels are explicit and cancellable
奖励三选一、道具选择与目标选择、徽章替换/排序、杆后决策 SHALL 在确认前可见当前选中项，并允许取消（法律允许时）而不消耗资源或改变状态。

#### Scenario: Tool selection is cancelled
- **WHEN** 玩家打开道具选择器后取消
- **THEN** SHALL 不消耗任何道具，不改变球桌或手牌状态

#### Scenario: Badge replacement is confirmed
- **WHEN** 玩家槽满时选择新徽章
- **THEN** SHALL 明确显示被替换徽章与替换对象，确认后才生效，取消则保留原徽章

### Requirement: Run statistics are visible after completion
Run 结束 SHALL 展示：各桌结果、已装备徽章、道具使用记录、最终得分与本地 JSON 导出提示，且全部为简体中文。

#### Scenario: Run completes
- **WHEN** 玩家胜利、失败或放弃当前 Run
- **THEN** 统计面板 SHALL 显示完整 Run 摘要并允许返回主菜单

### Requirement: Tutorial guides the first table step by step
教程桌 SHALL 提供逐步中文引导，覆盖瞄准、出杆、组合、结算、保留与爆仓，且玩家仅凭引导文字即可完成。

#### Scenario: A new player follows the tutorial
- **WHEN** 玩家进入教程并跟随逐步提示
- **THEN** SHALL 能独立完成一次组合结算并理解爆仓风险，无需外部说明
