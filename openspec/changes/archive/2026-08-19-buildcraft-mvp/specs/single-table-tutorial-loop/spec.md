## MODIFIED Requirements

### Requirement: Core state and available actions are always visible
可玩界面 SHALL 继续清晰显示 M2 核心状态，并在 M3 增加最多五枚有序徽章、触发预览、最终得分公式、道具栏、当前桌/Run 进度与奖励入口。默认玩家可见文字 SHALL 使用简体中文；内部规则 ID 不得直接作为标签显示。

#### Scenario: Player is aiming
- **WHEN** 球桌处于瞄准状态
- **THEN** 界面 SHALL 用中文显示目标分、当前分、剩余杆数、力度、辅助模式、Build、道具和可用出杆动作

#### Scenario: Player is deciding after a shot
- **WHEN** 球桌处于杆后决策状态
- **THEN** 界面 SHALL 用中文突出最佳组合、参与/污染槽位、M2 基础分、徽章步骤、最终分及合法结算/保留/道具动作

#### Scenario: Wall effect changes a slot
- **WHEN** 复制或染色效果修改当前球组
- **THEN** 对应实体、墙体、槽位与徽章预览 SHALL 提供中文可追踪反馈且与规则快照一致

### Requirement: Tutorial table has a reproducible complete setup
原 M2 固定 Seed 教程桌 SHALL 继续作为可独立进入的规则教学与回归入口，不因三桌 Run 被删除。主入口 SHALL 提供中文的“教程”和“开始巡回”选择；教程重置仍恢复完全相同初态。

#### Scenario: Resetting the tutorial
- **WHEN** 玩家在任意阶段选择重置教程桌
- **THEN** 球体、状态、球槽、墙充能、分数、杆数、Seed 和阶段 SHALL 恢复声明初态

#### Scenario: Starting setup supports the core loop
- **WHEN** 教程桌首次加载
- **THEN** 该固定配置 SHALL 继续支持物理收球、功能墙加工和有效组合结算

#### Scenario: Player opens the main entry
- **WHEN** M3 候选启动
- **THEN** 玩家 SHALL 能用中文明确选择教程或三桌 Run，且两者使用同一 M1/M2 规则实现
