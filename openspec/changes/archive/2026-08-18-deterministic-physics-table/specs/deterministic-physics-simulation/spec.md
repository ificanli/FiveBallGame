## Purpose

定义技术球桌可依赖的确定性运动与碰撞行为，使相同版本、初态和输入能够产生可复现的事件、停止时机与最终状态。

## ADDED Requirements

### Requirement: Fixed-step deterministic simulation
系统 SHALL 使用与渲染帧率解耦的固定时间步长推进所有球体，并 SHALL 在相同物理版本、初始快照和出杆输入下产生一致的规则结果。

#### Scenario: Repeating an identical shot
- **WHEN** 同一案例在同一平台和版本中从相同快照与输入重复运行 100 次
- **THEN** 每次运行 SHALL 产生相同的事件序列、最终规则状态、tick 数和状态 Hash

#### Scenario: Different render rates
- **WHEN** 同一案例分别以不同显示帧率驱动表现层
- **THEN** 模拟结果 SHALL 不因显示帧率而改变

### Requirement: Circular ball collision
系统 SHALL 模拟一颗母球与六颗等质量数字球之间的二维圆—圆碰撞，并 SHALL 防止最大力度下出现可观察的穿球、持续重叠或非有限速度。

#### Scenario: Direct equal-mass collision
- **WHEN** 运动球正面撞击静止的等质量球
- **THEN** 两球 SHALL 按配置的恢复损耗交换主要动量，且不得保持穿透重叠

#### Scenario: Glancing collision
- **WHEN** 运动球以非中心偏移量擦碰静止球
- **THEN** 系统 SHALL 沿接触法线解析冲量并保留可验证的切向分量

#### Scenario: Initial overlap
- **WHEN** 案例初态或数值误差导致两个球体重叠
- **THEN** 系统 SHALL 进行确定性的重叠修正，且不得生成能量爆炸或 NaN 状态

### Requirement: Rail collision
系统 SHALL 对球与技术桌标准库边的碰撞进行确定性反射，并应用独立于球球碰撞的可配置能量损耗。

#### Scenario: Perpendicular rail impact
- **WHEN** 球垂直撞击标准库边
- **THEN** 法向速度 SHALL 反向并按库边恢复参数衰减，切向方向 SHALL 保持

#### Scenario: Corner approach
- **WHEN** 球在一个固定步长内接近相邻两条库边
- **THEN** 系统 SHALL 在不穿出桌面的前提下以稳定顺序解析接触

### Requirement: Friction and shot termination
系统 SHALL 按模拟时间应用摩擦，SHALL 将低于停止阈值的球确定性吸附到静止，并 SHALL 在所有球停止后结束本杆。

#### Scenario: Natural slowdown
- **WHEN** 一个未再发生碰撞的球持续运动
- **THEN** 其速度 SHALL 单调衰减并在有限 tick 内变为精确零

#### Scenario: Low-speed tail
- **WHEN** 所有运动球均低于低速收尾阈值
- **THEN** 系统 SHALL 在配置的短收尾窗口内停止所有球，避免长时间爬行

#### Scenario: Maximum shot duration
- **WHEN** 一杆因低速多球运动超过配置的最大时长
- **THEN** 系统 SHALL 使用确定性的平滑收尾结束运动，不得瞬移球体或丢弃已经发生的有效事件

### Requirement: Physics state is independent of presentation nodes
规则快照 SHALL 完整包含重放运动所需的球体与桌面数据，且场景节点、动画和粒子状态 MUST NOT 成为模拟输入或规则真相。

#### Scenario: Headless execution
- **WHEN** 技术案例在无渲染节点的 Headless 环境运行
- **THEN** 它 SHALL 产生与同版本可视运行相同的规则结果
