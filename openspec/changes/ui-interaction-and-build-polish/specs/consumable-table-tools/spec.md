# consumable-table-tools Specification

## Purpose
M3.5 为六种道具补全选择与目标选择的界面，不改动道具的规则语义、消耗与原子效果。

## MODIFIED Requirements

### Requirement: Tools are limited resources with explicit legality
M3.5 SHALL 保持六种道具的规则语义、合法时机、消耗与原子效果不变；玩家 SHALL 通过道具选择器选择具体道具与合法目标，确认前可取消。取消不消耗道具或改变状态。

#### Scenario: Player cancels target selection
- **WHEN** 玩家选择需要目标的道具后取消
- **THEN** 道具数量与 Run/球桌快照 SHALL 保持不变

#### Scenario: Tool command is replayed
- **WHEN** 相同快照接收相同道具 ID 和目标 ID
- **THEN** 规则事件、道具数量、球槽、球状态和最终 Hash SHALL 相同

#### Scenario: Player picks a specific tool
- **WHEN** 玩家打开道具选择器并选中某一道具与目标
- **THEN** 仅该道具按 M3 规则被消耗并生效
