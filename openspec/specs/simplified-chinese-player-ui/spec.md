# simplified-chinese-player-ui Specification

## Purpose
TBD - created by archiving change buildcraft-mvp. Update Purpose after archive.

## Requirements

### Requirement: Simplified Chinese is the default player-facing language
M3 默认玩家可见界面 SHALL 使用简体中文，包括 HUD、按钮、按键提示、阶段、错误、组合名、徽章、道具、奖励、球桌名、胜负和统计。不得在默认流程中显示 `SETTLE`、`KEEP`、`BUST`、`WIN`、`LOSS`、`TARGET`、`SCORE`、`STROKES`、`RESET` 等英文原型词。

#### Scenario: Player completes the full run path
- **WHEN** 玩家从开局奖励进入三桌、使用道具并到达 Run 结算
- **THEN** 所有必要操作与状态 SHALL 可只阅读简体中文完成

#### Scenario: Internal state is shown to the player
- **WHEN** UI 渲染 `post_shot_decision`、`won` 或 `lost` 等内部状态
- **THEN** SHALL 通过本地化键显示“杆后决策”“胜利”或“失败”，不得直接显示内部 ID

### Requirement: Localization is keyed and separated from deterministic rule data
规则快照、回放、存档、配置 ID 和测试断言 SHALL 保持稳定英文键；表现层 SHALL 通过本地化表把键映射到中文。Hash 和跨平台对照 SHALL 排除本地化文本。

#### Scenario: Chinese wording changes
- **WHEN** 仅修改一个中文翻译而不修改规则键
- **THEN** 物理、规则回放和 Run 状态 Hash SHALL 保持不变

### Requirement: Localization coverage is automatically audited
CI SHALL 扫描所有玩家可见本地化键、18 枚徽章、6 种道具、组合、桌名和结果文本，拒绝缺失、空字符串、重复键或默认界面的已知英文原型词。

#### Scenario: A badge description is missing
- **WHEN** 某徽章配置引用不存在的中文说明键
- **THEN** 本地化审计 SHALL 失败并指出徽章 ID 与缺失键

#### Scenario: English prototype label regresses
- **WHEN** 玩家界面脚本重新出现已禁用英文标签
- **THEN** UI 文本审计 SHALL 失败

### Requirement: Chinese text remains readable in supported layouts
简体中文 SHALL 使用项目内可发布字体或经验证的 Godot 字体回退，并在 1280×720 与 1920×1080 下不出现方框字、关键按钮截断或规则文本遮挡。必要长说明 SHALL 支持换行和滚动，而非缩到不可读。

#### Scenario: Reward card shows the longest description
- **WHEN** 奖励界面显示最长的中文徽章或道具说明
- **THEN** 名称、效果、流派标签与选择按钮 SHALL 同时可读且不互相覆盖
