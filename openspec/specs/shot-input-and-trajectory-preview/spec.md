# shot-input-and-trajectory-preview Specification

## Purpose

定义可复现的五档出杆输入与三档轨迹辅助行为，使玩家看到的关键预测和真正发生的运动共享同一套物理规则。

## Requirements


### Requirement: Five discrete power levels
系统 SHALL 提供 `1` 至 `5` 五个离散力度档位；每个档位 SHALL 映射到固定初速度，实际出杆不得保留档间连续速度。

#### Scenario: Selecting a power level
- **WHEN** 玩家确认任意一个合法力度档位
- **THEN** 出杆输入 SHALL 记录该档位，并使用该档位当前物理版本定义的固定初速度

#### Scenario: Repeating a level and direction
- **WHEN** 玩家从相同初态重复选择相同方向和力度档位
- **THEN** 系统 SHALL 生成等价的出杆输入和模拟结果

#### Scenario: Invalid power level
- **WHEN** 输入包含小于 1 或大于 5 的力度档位
- **THEN** 系统 SHALL 拒绝该输入且不得推进模拟

### Requirement: Quantized reproducible direction
出杆方向 SHALL 以可序列化、可稳定比较的形式记录，并 SHALL 在回放时恢复同一方向；母球位置与方向输入必须通过合法性校验。

#### Scenario: Replay shot direction
- **WHEN** 已接受的出杆输入被序列化后再次加载
- **THEN** 恢复出的方向 SHALL 产生与原输入相同的首碰与最终规则结果

#### Scenario: Zero direction
- **WHEN** 输入方向无有效长度或包含非有限数值
- **THEN** 系统 SHALL 拒绝出杆且不得消耗一次技术案例运行

### Requirement: Three assistance modes
系统 SHALL 提供简洁、标准和完整三档辅助模式；辅助模式只改变展示的信息范围，不得改变正式出杆输入或物理结果。

#### Scenario: Concise assistance
- **WHEN** 辅助模式为简洁
- **THEN** 系统 SHALL 至少显示母球第一段路径和首个被撞球的短出射方向

#### Scenario: Standard assistance
- **WHEN** 辅助模式为标准
- **THEN** 系统 SHALL 显示母球首碰前路径、幽灵接触位置、母球碰后短方向、首个被撞数字球到下一次碰撞的主要路径，并在预计触发功能墙时标明球与墙

#### Scenario: Full assistance
- **WHEN** 辅助模式为完整
- **THEN** 系统 SHALL 展示比标准模式更长的受限连锁预测，但不得自动推荐最佳球路

### Requirement: Preview and motion share the same simulation rules
辅助预测 SHALL 从与正式运动相同的初始快照调用同一物理模拟行为；不得维护第二套碰撞、摩擦或墙体反射公式。

#### Scenario: First collision agreement
- **WHEN** 玩家按当前预测对应的输入出杆且初态未改变
- **THEN** 正式运动的首个有效碰撞对象、碰撞类型和接触顺序 SHALL 与预测一致

#### Scenario: Wall-effect preview
- **WHEN** 标准或完整预测判定某颗激活数字球将触发功能墙
- **THEN** 正式运动在相同输入下 SHALL 由同一颗球触发同一面墙，除非预测因显示长度限制明确标记为未覆盖
