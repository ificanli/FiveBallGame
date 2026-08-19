# post-shot-decision-and-bust Specification

## Purpose

定义单杆消耗、运动期间收球、杆后结算或保留以及第六球爆仓的统一时序，确保球槽、累计分和物理球状态不会出现半更新。

## Requirements

### Requirement: A valid shot consumes one stroke at launch
教程桌 SHALL 仅在有效出杆被正式提交并开始模拟时消耗一杆。瞄准、切换力度、取消输入、无效输入和杆后决策不得消耗杆数；球仍在运动或处于终态时不得再次出杆。

#### Scenario: Player launches a valid shot
- **WHEN** 玩家在可瞄准状态提交有效角度与力度且剩余杆数大于零
- **THEN** 剩余杆数 SHALL 立即减少一并进入运动状态

#### Scenario: Player adjusts aim
- **WHEN** 玩家只调整角度、辅助模式或力度而未提交出杆
- **THEN** 剩余杆数 SHALL 保持不变

#### Scenario: Player attempts a second shot while balls move
- **WHEN** 任意球仍在当前杆中运动
- **THEN** 系统 SHALL 拒绝新的出杆且不得再次扣杆

### Requirement: Shot completion opens an explicit decision when a hand exists
所有球停止后，若球槽非空且未爆仓，系统 SHALL 进入杆后决策并提供结算与保留；若球槽为空且仍有杆数，系统 SHALL 直接返回瞄准。杆后决策完成前不得开始下一杆。

#### Scenario: Shot ends with a non-empty hand
- **WHEN** 所有球停止且当前球槽包含至少一格
- **THEN** 系统 SHALL 显示最佳组合、基础得分，并等待玩家选择结算或保留

#### Scenario: Shot ends without collecting a ball
- **WHEN** 所有球停止且当前球槽为空且仍有剩余杆数
- **THEN** 系统 SHALL 直接允许下一杆，不显示无意义的结算决策

### Requirement: Settlement banks the previewed score atomically
玩家选择结算时，系统 SHALL 将当前预览基础得分一次性加入本桌累计分，清空全部球槽，并将所有对应物理本手球转为废球。纯槽位副本 SHALL 随球槽清空且不得产生物理废球。

#### Scenario: Player settles a mixed hand
- **WHEN** 玩家在杆后决策选择结算
- **THEN** 累计分 SHALL 只增加已显示的最佳组合基础得分，球槽 SHALL 清空，所有物理本手球 SHALL 转为废球

#### Scenario: Settlement reaches target
- **WHEN** 结算后的累计分达到或超过教程桌目标分
- **THEN** 系统 SHALL 立即进入胜利终态且不得允许额外出杆

### Requirement: Keep preserves the current hand for another shot
玩家选择保留时，当前球槽、本手球状态、纯槽位副本和累计分 SHALL 保持不变，并在仍有剩余杆数时开始下一次瞄准。保留本身不得得分或消耗额外杆数。

#### Scenario: Player keeps with strokes remaining
- **WHEN** 玩家选择保留且剩余杆数大于零
- **THEN** 系统 SHALL 返回瞄准状态，完整保留当前球组并等待下一次出杆

#### Scenario: No strokes remain after the shot
- **WHEN** 当前杆停止后剩余杆数为零且球槽非空
- **THEN** 玩家 SHALL 仍可结算当前球组，但 SHALL NOT 获得保留选项或再次出杆

### Requirement: Acquiring a sixth slot causes immediate bust
当五个槽位已满后又将获得第六个物理收集槽或复制槽时，系统 SHALL 在对应收集或复制事件发生的 tick 立即爆仓：清空当前球组、将原五格及触发第六格对应的所有物理本手球转为废球、本手得分记为零，并锁定本杆后续收集与功能墙加工。当前物理模拟 SHALL 继续到所有球停止。

#### Scenario: Sixth physical ball is collected
- **WHEN** 五槽已满且激活链首次有效碰撞第六颗未收球
- **THEN** 系统 SHALL 立即爆仓，第六球 SHALL 与原有物理本手球一同转为废球，累计分 SHALL 不变

#### Scenario: Copy wall would create a sixth slot
- **WHEN** 五槽已满且激活球成功触发有充能复制墙
- **THEN** 系统 SHALL 立即爆仓，纯复制结果 SHALL 不留在槽中，触发墙充能 SHALL 按成功触发消耗

#### Scenario: Collisions continue after bust
- **WHEN** 爆仓发生时仍有球在运动
- **THEN** 物理模拟 SHALL 继续，但本杆剩余事件不得再收球、复制或染色，且累计分 SHALL 不被扣除

### Requirement: Zero strokes resolves to a terminal result
最后一杆停止后，系统 SHALL 先允许非爆仓球组进行一次最终结算；该结算若未达到目标，或最后一杆为空/爆仓且累计分未达目标，系统 SHALL 进入失败终态。

#### Scenario: Final settlement misses target
- **WHEN** 零杆状态下玩家结算最后球组且累计分仍低于目标
- **THEN** 系统 SHALL 进入失败终态

#### Scenario: Final shot busts below target
- **WHEN** 最后一杆爆仓停止且累计分低于目标
- **THEN** 系统 SHALL 直接进入失败终态且不得出现结算或保留选项
