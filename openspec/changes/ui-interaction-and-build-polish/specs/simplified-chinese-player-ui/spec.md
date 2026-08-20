# simplified-chinese-player-ui Specification

## Purpose
M3.5 把简体中文玩家界面从手绘 HUD 升级为 Godot Control 节点 UI，保持本地化键与英文内部 ID 分离，仍禁止默认界面出现英文原型词。

## MODIFIED Requirements

### Requirement: Simplified Chinese is the default player-facing language
M3.5 默认玩家可见界面 SHALL 继续使用简体中文，覆盖主菜单、暂停、奖励、道具选择器、徽章管理、杆后决策、结算、爆仓、统计、教程、HUD、按钮、按键提示、流派标签、徽章、道具、球桌名与胜负。UI 从手绘升级为节点后，SHALL NOT 在默认流程中重新出现 `SETTLE`、`KEEP`、`BUST`、`WIN`、`LOSS`、`TARGET`、`SCORE`、`STROKES`、`RESET` 等英文原型词。

#### Scenario: Player completes the full run path
- **WHEN** 玩家从主菜单经开局奖励、三桌、道具、徽章管理并到达 Run 结算
- **THEN** 所有必要操作与状态 SHALL 可只阅读简体中文完成

#### Scenario: Internal state is shown to the player
- **WHEN** UI 渲染 `post_shot_decision`、`won` 或 `lost` 等内部状态
- **THEN** SHALL 通过本地化键显示"杆后决策""胜利"或"失败"，不得直接显示内部 ID

#### Scenario: English prototype label regresses in a node
- **WHEN** 任一 UI 节点重新出现已禁用英文标签
- **THEN** UI 文本审计 SHALL 失败

### Requirement: Localization is keyed and separated from deterministic rule data
规则快照、回放、存档、配置 ID 和测试断言 SHALL 保持稳定英文键；表现层 SHALL 通过本地化表把键映射到中文。Hash 和跨平台对照 SHALL 排除本地化文本与流派视觉标识。

#### Scenario: Chinese wording changes
- **WHEN** 仅修改一个中文翻译或流派视觉标识而不修改规则键
- **THEN** 物理、规则回放和 Run 状态 Hash SHALL 保持不变

### Requirement: Chinese text remains readable in supported layouts
简体中文 SHALL 使用项目内可发布字体或经验证的 Godot 字体回退，并在 1280×720 与 1920×1080 下不出现方框字、关键按钮截断或规则文本遮挡。必要长说明 SHALL 支持换行和滚动，而非缩到不可读。

#### Scenario: Reward card shows the longest description
- **WHEN** 奖励界面显示最长的中文徽章或道具说明
- **THEN** 名称、说明、流派标签与选择按钮 SHALL 同时可读且不互相覆盖
