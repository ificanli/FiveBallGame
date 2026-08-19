# controlled-replenishment Specification

## Purpose
TBD - created by archiving change buildcraft-mvp. Update Purpose after archive.

## Requirements

### Requirement: Settlement and bust replenish to a table target
每次结算或爆仓完成后，若球桌仍在进行，系统 SHALL 补充未收球到当前桌配置目标：资格桌 6、高额桌 8、庄家桌 10。补球不得改变废球、本手球、累计分、剩余杆数或徽章状态。

#### Scenario: Settlement leaves too few uncollected balls
- **WHEN** 一次结算后未收球少于桌级目标且本桌未结束
- **THEN** 系统 SHALL 仅补足差额并记录每颗新球的稳定 ID、数字、颜色和生成点

#### Scenario: Table already has enough targets
- **WHEN** 结算后未收球数量达到或超过目标
- **THEN** 系统 SHALL 不生成新球且随机流计数不得推进

### Requirement: Replenishment is deterministic and spatially legal
补球 SHALL 从 Run Seed 派生的独立随机流和版本化投放点生成。候选位置不得与任何球、墙或母球保护区重叠；同一输入 SHALL 选择相同数字、颜色和位置。若有限候选均非法，系统 SHALL 返回明确失败并进入可恢复状态，不得重叠硬塞。

#### Scenario: Same replenishment is replayed
- **WHEN** 相同规则版本、Seed、随机计数器和球桌快照执行补球
- **THEN** 新球列表、事件顺序和状态 Hash SHALL 相同

#### Scenario: All spawn points are blocked
- **WHEN** 所有声明投放点均无法满足最小间距
- **THEN** 系统 SHALL 记录 `replenishment_blocked`，不生成重叠球且允许玩家使用清台重开

### Requirement: Controlled generation preserves a basic opportunity without gifting the best hand
补球批次 SHALL 在合法候选中保证桌面至少存在一种可通过未来收集形成的基础对子或三球顺/同色机会，但 SHALL NOT 直接保证同色顺、炸弹或五球满贯。该约束 SHALL 只读取未收球池，不修改已存在球。

#### Scenario: Random batch has no basic opportunity
- **WHEN** 初次确定性抽样无法与现有未收球形成声明的基础机会
- **THEN** 生成器 SHALL 使用有界、版本化的确定性修正规则替换批次中的最少条目

### Requirement: Density has an absolute deterministic safety bound
结算或爆仓后的废球数量超过配置软上限时，系统 SHALL 按成为废球的事件顺序移除最旧超额实体，保留最新 10 颗。自动清理 SHALL 不得得分、触发徽章或消耗道具。

#### Scenario: Waste count exceeds ten
- **WHEN** 一次状态转换后桌面存在 12 颗废球
- **THEN** 最旧两颗 SHALL 被确定性移除并产生明确的性能保护事件
