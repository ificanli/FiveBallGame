## Purpose

定义数字球从首次有效碰撞到结算或爆仓后的完整生命周期，使球槽归属、物理留场与功能墙资格在所有回合中保持一致且可验证。

## ADDED Requirements

### Requirement: First valid activated contact collects a number ball
未收数字球在本杆中首次被母球或激活数字球有效碰撞时 SHALL 进入本手球状态并加入当前球槽。每颗物理数字球 SHALL 使用稳定唯一 ID 关联至其槽位。

#### Scenario: Cue ball collects an uncollected ball
- **WHEN** 母球首次有效碰撞一颗未收数字球且球槽仍可接纳该球
- **THEN** 该球 SHALL 变为本手球，球槽 SHALL 新增一格并保存该物理球 ID

#### Scenario: Activated ball collects through a chain
- **WHEN** 激活数字球有效碰撞一颗未收数字球且球槽仍可接纳该球
- **THEN** 后者 SHALL 被激活并按同一规则变为本手球

### Requirement: Collected physical balls remain on the table
本手球与废球 SHALL 保留为物理实体，继续参与运动、球球碰撞和普通库边反弹；状态转换不得移动、删除或重置该球的运动状态。

#### Scenario: A hand ball is struck again
- **WHEN** 已处于本手球状态的物理球再次参与碰撞
- **THEN** 它 SHALL 继续传递动量且不得重复加入球槽

#### Scenario: A waste ball is used as a bank object
- **WHEN** 运动球撞击一颗废球
- **THEN** 废球 SHALL 按普通等质量数字球参与碰撞，但不得再次收集

### Requirement: Number balls have exactly three persistent collection states
每颗物理数字球的持久收集状态 SHALL 为未收球、本手球或废球之一。未收球可被收集；本手球对应当前球组；废球不可再次收集且不可恢复为未收球。

#### Scenario: Settlement converts hand balls to waste
- **WHEN** 当前球组成功结算
- **THEN** 所有具有物理 ID 的本手球 SHALL 原子地转为废球

#### Scenario: Bust converts involved balls to waste
- **WHEN** 当前球组发生六球爆仓
- **THEN** 原五格及触发第六格所对应的所有物理球 SHALL 转为废球

#### Scenario: Waste ball is contacted in a later shot
- **WHEN** 母球或激活球在后续杆碰撞废球
- **THEN** 废球 SHALL 保持废球状态且不得进入球槽或成为可加工球

### Requirement: Presentation exposes lifecycle without changing rule truth
教程桌 SHALL 以可区分的视觉状态显示未收球、本手球与废球，并 SHALL 从规则快照读取状态；表现节点的样式或动画状态 MUST NOT 决定收集资格。

#### Scenario: Rule snapshot marks a ball as hand state
- **WHEN** 表现层收到某球为本手球的规则快照
- **THEN** 该球 SHALL 显示醒目的本手归属标记，且对应槽位 SHALL 可追溯到同一 ID

#### Scenario: Rule snapshot marks a ball as waste
- **WHEN** 表现层收到某球为废球的规则快照
- **THEN** 该球 SHALL 显示低饱和废球外观而不依赖常驻“已收”文字
