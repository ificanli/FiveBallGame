## MODIFIED Requirements

### Requirement: Activation follows collision causality
母球首次有效撞击未收数字球后，该数字球 SHALL 被激活并按球槽规则尝试收集；激活数字球有效撞击其他未收数字球时 SHALL 能传递激活状态并尝试收集。系统 SHALL 记录激活来源与事件顺序。本手球可在未爆仓的当前杆继续保持激活资格；废球与爆仓后本杆中的所有数字球不得触发功能墙加工。

#### Scenario: Cue ball activates a number ball
- **WHEN** 母球首次有效撞击未收数字球
- **THEN** 该数字球 SHALL 进入激活状态、记录母球为来源并按球槽容量尝试收集

#### Scenario: Activated ball propagates activation
- **WHEN** 激活数字球有效撞击未收数字球
- **THEN** 后者 SHALL 进入激活状态、记录前者为来源并按球槽容量尝试收集

#### Scenario: Non-activated ball touches a function wall
- **WHEN** 未激活数字球撞击功能墙
- **THEN** 墙体 SHALL 只产生普通反弹，不得应用加工效果

#### Scenario: Waste ball touches a function wall
- **WHEN** 废球撞击复制墙或染色墙
- **THEN** 墙体 SHALL 只产生普通反弹，不得消耗充能或修改球槽

### Requirement: Copy wall affects the actual impacting active ball
复制墙 SHALL 在有充能且本杆未爆仓时，为实际撞墙的激活本手球尝试创建一格同数字同颜色的纯槽位副本；副本 SHALL 无物理球 ID且不生成物理实体。母球、未激活球、废球和耗尽后的碰撞不得产生复制结果。成功创建第六格的尝试 SHALL 按爆仓规则处理。

#### Scenario: Active number ball hits charged copy wall
- **WHEN** 一颗激活本手球实际撞击有充能的复制墙且球槽少于五格
- **THEN** 系统 SHALL 创建与该球数字和颜色相同的纯槽位副本并消耗一次墙体充能

#### Scenario: Active hand ball would create a sixth slot
- **WHEN** 一颗激活本手球在五槽已满时撞击有充能的复制墙
- **THEN** 系统 SHALL 消耗墙体充能并触发爆仓，不得保留第六格副本

#### Scenario: Cue ball hits copy wall
- **WHEN** 母球撞击复制墙
- **THEN** 母球 SHALL 正常反弹且不得产生复制事件

#### Scenario: Copy wall is exhausted
- **WHEN** 当前杆的复制墙充能已经耗尽后再次被撞击
- **THEN** 墙体 SHALL 正常反弹且不得产生第二次复制事件

### Requirement: Dye wall changes the actual impacting active ball
染色墙 SHALL 在本杆未爆仓时将实际撞墙的激活本手球颜色改为墙体颜色并保留数字，同时 SHALL 通过该球唯一 ID 同步修改对应物理收集槽，并记录球 ID、旧颜色和新颜色。纯槽位副本无物理 ID，后续不得作为染色目标。

#### Scenario: Active number ball hits dye wall
- **WHEN** 一颗激活本手球实际撞击染色墙
- **THEN** 该物理球及保存同一物理球 ID 的槽位 SHALL 同步变为墙体颜色、数字保持不变

#### Scenario: Another active ball was activated later
- **WHEN** 多颗球已激活但只有其中一颗实际撞击染色墙
- **THEN** 只有实际撞墙球及其 ID 对应槽位 SHALL 被染色，不得修改“最近激活”、其他球或纯槽位副本

#### Scenario: Cue ball hits dye wall
- **WHEN** 母球撞击染色墙
- **THEN** 母球 SHALL 正常反弹且不得获得颜色或产生染色事件

#### Scenario: Waste ball hits dye wall
- **WHEN** 废球实际撞击染色墙
- **THEN** 废球 SHALL 正常反弹且其颜色及所有槽位 SHALL 不变

### Requirement: Wall effects integrate with the single-player hand
复制与染色事件 SHALL 在发生的模拟 tick 内通过同一规则状态机原子更新球槽、球状态、墙体充能及爆仓结果，同时保留可测试的事件记录。M2 SHALL NOT 因该集成引入徽章、奖励、长局 Run 或 PvP 规则。

#### Scenario: Shot ends after wall events
- **WHEN** 一杆包含成功复制或染色并最终停止且未爆仓
- **THEN** 杆后最佳组合与得分预览 SHALL 基于墙体加工后的最终球槽

#### Scenario: Headless replay consumes wall events
- **WHEN** 相同规则版本、初态和输入在 Headless 环境重放
- **THEN** 墙体事件、球槽更新、爆仓结果与最终状态 Hash SHALL 可复现
