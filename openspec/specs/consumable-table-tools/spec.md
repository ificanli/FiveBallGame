# consumable-table-tools Specification

## Purpose
TBD - created by archiving change buildcraft-mvp. Update Purpose after archive.

## Requirements

### Requirement: M3 has six distinct consumable tools
M3 道具池 SHALL 恰好包含软袋、保险球槽、调色粉笔、数字贴纸、退球钩、清台重开六种道具。每种 SHALL 具有唯一稳定 ID、中文名称、中文说明、携带数量、合法阶段、目标过滤器和确定性效果。

#### Scenario: Tool catalog audit runs
- **WHEN** CI 加载道具配置
- **THEN** SHALL 验证六个 ID 唯一、中文键完整、目标规则存在且奖励池不包含无效条目

### Requirement: Tools are limited resources with explicit legality
Run SHALL 最多携带三张道具卡；同 ID 可按配置叠加数量。只有所有球停止且当前阶段允许时才可使用，道具命令 SHALL 先完整验证再原子消耗。非法目标、错误阶段或取消选择不得消耗道具或改变状态。

#### Scenario: Player cancels target selection
- **WHEN** 玩家选择需要目标的道具后取消
- **THEN** 道具数量与 Run/球桌快照 SHALL 保持不变

#### Scenario: Tool command is replayed
- **WHEN** 相同快照接收相同道具 ID 和目标 ID
- **THEN** 规则事件、道具数量、球槽、球状态和最终 Hash SHALL 相同

### Requirement: Bust protection is owned before the risk
软袋 SHALL 在下一次第六槽产生前被持有并启用，使第六颗物理球转为废球或丢弃第六个复制槽，同时保留原五槽；保险球槽 SHALL 允许一次临时第六槽参与杆后最佳组合，并强制结算、禁止保留。二者触发后消耗，且不得在爆仓结果出现后补用。

#### Scenario: Soft pocket intercepts a sixth physical ball
- **WHEN** 已启用软袋且五槽满时获得第六颗物理球
- **THEN** 第六球 SHALL 转为废球、原五槽保留、当前杆继续且软袋消耗

#### Scenario: Insurance slot accepts the sixth slot
- **WHEN** 已启用保险球槽且五槽满时获得第六格
- **THEN** 六格 SHALL 参与本杆最终组合评价，停止后只允许强制结算，随后恢复五槽容量并消耗道具

### Requirement: Editing tools synchronize rule truth
调色粉笔 SHALL 修改一颗当前本手实体球颜色；数字贴纸 SHALL 将一颗当前本手实体球数字调整 `+1` 或 `-1` 且保持在 1～9；退球钩 SHALL 将一颗当前本手实体球移出球槽并转为废球。修改 SHALL 同步物理实体、槽位、预览和回放；纯复制槽不得作为实体目标。

#### Scenario: Chalk recolors a hand ball
- **WHEN** 玩家用调色粉笔选择合法实体本手球和目标颜色
- **THEN** 物理球、对应槽位、最佳组合和结算预览 SHALL 同步更新

#### Scenario: Number sticker would exceed range
- **WHEN** 玩家尝试把 9 号球加一或 1 号球减一
- **THEN** 命令 SHALL 被拒绝且道具不消耗

### Requirement: Table reset tool does not undo earned outcomes
清台重开 SHALL 仅在杆后决策阶段使用，清除当前未结算球组与桌面数字球，并按本桌配置和确定性随机流重新摆入未收球；它 SHALL 保留本桌已结算分、剩余杆数、Run Build、桌规则与功能墙定义，且不返还已消耗杆数。

#### Scenario: Clearing a congested table
- **WHEN** 玩家合法使用清台重开
- **THEN** 新球 SHALL 合法无重叠，当前手清空，既有分数和杆数不变，道具消耗一张
