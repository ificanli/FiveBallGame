## MODIFIED Requirements

### Requirement: Acquiring a sixth slot causes immediate bust
默认情况下，五槽已满后获得第六个物理或复制槽 SHALL 立即爆仓并沿用 M2 原子转换。若爆仓发生前已合法启用软袋或保险球槽，状态机 SHALL 分别执行其声明的前置保护；保护事件 SHALL 在普通爆仓判断前按固定优先级消费，且每次只允许一种保护生效。

#### Scenario: Sixth physical ball is collected
- **WHEN** 五槽已满、未启用保护且激活链首次有效碰撞第六颗未收球
- **THEN** 系统 SHALL 按 M2 规则立即爆仓并将涉及物理球转为废球

#### Scenario: Copy wall would create a sixth slot
- **WHEN** 五槽已满、未启用保护且复制墙将创建第六槽
- **THEN** 系统 SHALL 按 M2 规则立即爆仓并消耗该次成功触发的墙体充能

#### Scenario: Collisions continue after bust
- **WHEN** 无保护爆仓发生时仍有球运动
- **THEN** 物理 SHALL 继续，但后续收球和功能墙加工仍被锁定

#### Scenario: Multiple protections are available
- **WHEN** 玩家同时持有软袋与保险球槽但只启用了其中一种
- **THEN** 只有已启用道具 SHALL 参与第六槽归约，另一张不得被自动消耗

### Requirement: Shot completion opens an explicit decision when a hand exists
所有球停止后，若球槽非空且未爆仓，系统 SHALL 进入杆后决策并显示结算、保留及当前合法道具；若保险球槽产生六格手牌，系统 SHALL 只允许结算及不改变球组的合法操作，禁止保留。所有按钮 SHALL 从规则命令合法性派生。

#### Scenario: Shot ends with a non-empty hand
- **WHEN** 所有球停止且当前球槽为一至五格
- **THEN** 系统 SHALL 显示徽章后的最终得分以及合法的结算、保留和道具动作

#### Scenario: Shot ends without collecting a ball
- **WHEN** 所有球停止且球槽为空、仍有杆数
- **THEN** 系统 SHALL 返回中文瞄准界面并只显示当前阶段合法道具，不显示无意义结算

#### Scenario: Insured six-slot hand reaches decision
- **WHEN** 保险球槽成功接纳第六格且运动停止
- **THEN** 系统 SHALL 突出“必须结算”，禁用保留并显示六格最佳组合与最终分
