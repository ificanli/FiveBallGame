## Purpose

定义首张技术桌对激活传递、复制墙和染色墙的最小可观察规则，确保墙体加工对象由真实碰撞因果决定而非 UI 或全局捷径决定。

## ADDED Requirements

### Requirement: Fixed-seed technical table
系统 SHALL 能以固定 Seed 加载一张包含一颗无数字无颜色母球、六颗数字球、标准库边、至少一面复制墙和至少一面染色墙的技术桌。

#### Scenario: Loading the same seed
- **WHEN** 同一内容版本使用相同 Seed 创建技术桌
- **THEN** 球体标识、数字、颜色、位置与墙体配置 SHALL 相同

#### Scenario: Cue-ball identity
- **WHEN** 技术桌加载完成
- **THEN** 母球 SHALL 无数字、无颜色且不得作为可加工数字球

### Requirement: Activation follows collision causality
母球首次有效撞击数字球后，该数字球 SHALL 被标记为本杆激活；激活数字球有效撞击其他数字球时 SHALL 能传递激活状态。系统 SHALL 记录激活来源与事件顺序。

#### Scenario: Cue ball activates a number ball
- **WHEN** 母球首次有效撞击未激活数字球
- **THEN** 该数字球 SHALL 进入激活状态并记录母球为来源

#### Scenario: Activated ball propagates activation
- **WHEN** 激活数字球有效撞击未激活数字球
- **THEN** 后者 SHALL 进入激活状态并记录前者为来源

#### Scenario: Non-activated ball touches a function wall
- **WHEN** 未激活数字球撞击功能墙
- **THEN** 墙体 SHALL 只产生普通反弹，不得应用加工效果

### Requirement: Copy wall affects the actual impacting active ball
复制墙 SHALL 在有充能时，为实际撞墙的激活数字球产生一条复制结果事件；母球、未激活球和耗尽后的碰撞不得产生复制结果。

#### Scenario: Active number ball hits charged copy wall
- **WHEN** 一颗激活数字球实际撞击有充能的复制墙
- **THEN** 系统 SHALL 记录与该球数字和颜色相同的复制结果，并消耗一次墙体充能

#### Scenario: Cue ball hits copy wall
- **WHEN** 母球撞击复制墙
- **THEN** 母球 SHALL 正常反弹且不得产生复制事件

#### Scenario: Copy wall is exhausted
- **WHEN** 当前杆的复制墙充能已经耗尽后再次被撞击
- **THEN** 墙体 SHALL 正常反弹且不得产生第二次复制事件

### Requirement: Dye wall changes the actual impacting active ball
染色墙 SHALL 将实际撞墙的激活数字球颜色改为墙体颜色并保留数字，同时 SHALL 记录包含球 ID、旧颜色和新颜色的染色事件。

#### Scenario: Active number ball hits dye wall
- **WHEN** 一颗激活数字球实际撞击染色墙
- **THEN** 该物理球 SHALL 改为墙体颜色、数字保持不变，事件 SHALL 指向该球唯一 ID

#### Scenario: Another active ball was activated later
- **WHEN** 多颗球已激活但只有其中一颗实际撞击染色墙
- **THEN** 只有实际撞墙球 SHALL 被染色，不得修改“最近激活”或其他球

#### Scenario: Cue ball hits dye wall
- **WHEN** 母球撞击染色墙
- **THEN** 母球 SHALL 正常反弹且不得获得颜色或产生染色事件

### Requirement: Wall effects remain a technical slice
本变更中的复制结果和染色状态 SHALL 可被测试与展示，但 SHALL NOT 引入组合评价、计分、结算/保留、五球槽或六球爆仓规则。

#### Scenario: Shot ends after wall events
- **WHEN** 一杆包含复制或染色事件并最终停止
- **THEN** 输出 SHALL 包含物理与墙体事件，但不得计算牌型、分数或球组决策
