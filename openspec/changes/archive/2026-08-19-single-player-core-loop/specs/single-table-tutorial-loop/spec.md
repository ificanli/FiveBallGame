## Purpose

定义一张无需长局构筑即可独立游玩的教程桌，让玩家完成瞄准、碰撞收球、功能墙加工、组合判断、保留冒险、结算及胜负闭环。

## ADDED Requirements

### Requirement: Tutorial table has a reproducible complete setup
教程桌 SHALL 由版本化配置和固定 Seed 建立，包含母球、足以形成基础组合的未收数字球、普通库边、复制墙、染色墙、目标分和有限杆数。重置 SHALL 恢复完全相同的规则初态。

#### Scenario: Resetting the tutorial
- **WHEN** 玩家在任意阶段选择重置教程桌
- **THEN** 球体、球状态、球槽、墙体充能、累计分、杆数、Seed 和回合状态 SHALL 恢复为声明的初态

#### Scenario: Starting setup supports the core loop
- **WHEN** 教程桌首次加载
- **THEN** 玩家 SHALL 能在该配置中完成至少一次物理收球、一次功能墙加工和一次有效组合结算

### Requirement: Core state and available actions are always visible
可玩界面 SHALL 清晰显示目标分、当前累计分、剩余杆数、最多五格球槽、各槽数字与颜色、当前最佳组合、参与球/污染球、基础得分预览、墙体充能以及当前允许的动作。

#### Scenario: Player is aiming
- **WHEN** 教程桌处于瞄准状态
- **THEN** 界面 SHALL 显示现有 M1 瞄准信息与可用出杆动作，结算和保留动作 SHALL 不可用

#### Scenario: Player is deciding after a shot
- **WHEN** 教程桌处于杆后决策状态
- **THEN** 界面 SHALL 突出最佳组合、参与槽位、污染槽位、结算可得分和当前可用的结算/保留动作

#### Scenario: Wall effect changes a slot
- **WHEN** 复制或染色效果修改当前球组
- **THEN** 对应物理球、墙体和槽位 SHALL 提供可追踪的归属反馈，且显示结果 SHALL 与规则快照一致

### Requirement: The tutorial table has explicit win and loss states
结算使累计分达到目标时 SHALL 立即胜利；所有可用杆数和最后结算机会耗尽后仍未达目标时 SHALL 失败。胜利与失败界面 SHALL 显示结果并提供使用同一配置重新开始的动作。

#### Scenario: Player wins
- **WHEN** 一次结算使累计分达到或超过目标
- **THEN** 界面 SHALL 显示胜利、最终分数和重开动作，并禁止继续出杆

#### Scenario: Player loses
- **WHEN** 最后机会处理完成且累计分低于目标
- **THEN** 界面 SHALL 显示失败、最终分数和重开动作，并禁止继续出杆

### Requirement: The loop remains deterministic and headless-verifiable
教程桌的规则结果 SHALL 仅由版本、固定 Seed、初始快照及离散玩家动作序列决定。系统 SHALL 能在无渲染环境重放跨多杆的出杆与决策，并输出每杆事件、球组、分数、杆数、终态和状态 Hash。

#### Scenario: Replaying an identical multi-shot session
- **WHEN** 同一教程案例从相同初态执行相同的出杆与结算/保留动作序列 100 次
- **THEN** 每次的事件顺序、逐杆快照、最终状态与 Hash SHALL 相同

#### Scenario: Presentation frame rate changes
- **WHEN** 同一动作序列由不同显示帧率的表现层驱动
- **THEN** 教程桌规则结果 SHALL 不变

### Requirement: Human acceptance covers comprehension and 15-minute stability
M2 候选构建 SHALL 经过真人从实际导出入口完成教程桌闭环，并连续操作至少 15 分钟。验收 SHALL 分别记录规则理解、结算/保留决策、爆仓可预见性、墙体归属及阻塞问题；自动测试不得替代该结论。

#### Scenario: Human completes acceptance session
- **WHEN** 真人在候选构建中连续游玩至少 15 分钟
- **THEN** 记录 SHALL 明确是否完成至少一次结算、一次保留后再出杆、一次复制或染色加工、一次爆仓以及一次胜利或失败重开，且 SHALL 记录任何阻塞 Bug
