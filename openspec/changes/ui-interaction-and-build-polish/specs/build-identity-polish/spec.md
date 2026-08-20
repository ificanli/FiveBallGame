# build-identity-polish Specification

## Purpose
M3.5 为三条打法提供肉眼可辨的视觉标识、完整中文说明与流派/角色标签，并通过平衡微调与真人可辨识验收证明“三套流派确实玩成不同路线”，而不只是数值装饰。

## ADDED Requirements

### Requirement: Every badge and tool has readable Simplified Chinese description
18 枚徽章与 6 种道具 SHALL 具备简体中文说明，内容 SHALL 写明触发条件、效果与数值；不得为空字符串、重复键或营销空话。

#### Scenario: Badge description is shown
- **WHEN** 玩家在奖励、徽章管理或结算明细中查看任意徽章
- **THEN** SHALL 显示该徽章的中文名称、说明与流派/角色标签

#### Scenario: Tool description is shown
- **WHEN** 玩家打开道具选择器查看任意道具
- **THEN** SHALL 显示该道具的中文说明、合法时机与消耗

### Requirement: Build identity is visually consistent
三条打法 SHALL 使用稳定的配色与文字标签（键：`pure_combo` / `rail_chain` / `wall_risk`），并在装备、奖励、结算明细与统计面板中保持一致。标识 SHALL NOT 进入规则数据、Hash 或回放。

#### Scenario: Same build across screens
- **WHEN** 同一流派出现在不同界面
- **THEN** 其配色与标签 SHALL 一致，且与真实触发条件相符

### Requirement: Build identity matches real trigger conditions
流派标识 SHALL 反映徽章真实读取的规则事件；不得出现“显示为连锁、实际只做无条件加分”的装饰性身份。

#### Scenario: Identity is verified against conditions
- **WHEN** 系统或 CI 审计某徽章的流派标签与触发条件
- **THEN** SHALL 拒绝标签与读取字段不一致的配置

### Requirement: Builds are distinguishable by human shot observation
三套代表性击球录像（隐藏分数 UI）SHALL 由产品负责人仅凭力度、撞库、连锁与功能墙选择判断所属流派；自动代理 SHALL NOT 代替该结论。

#### Scenario: Human reviews hidden-score recordings
- **WHEN** 真人观看隐藏分数 UI 的三套代表性击球录像
- **THEN** 验收记录 SHALL 判断是否能仅凭击球选择识别流派，并记录结论为人工证据

### Requirement: Balance tuning is evidence-led and reversible
平衡微调 SHALL 由确定性代理的反事实对照（同一桌面的“直取”与“流派路线”触发差异）产出候选，逐项记录调整前后数值；不得为抬高机器胜率而堆无条件强卡。

#### Scenario: A balance candidate is recorded
- **WHEN** 代理发现某流派路线触发显著低于或高于预期
- **THEN** SHALL 记录候选调整与反事实证据，经产品负责人确认后方可落库
