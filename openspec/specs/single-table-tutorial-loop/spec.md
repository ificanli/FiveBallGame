# single-table-tutorial-loop Specification

## Purpose

定义一张无需长局构筑即可独立游玩的教程桌，让玩家完成瞄准、碰撞收球、功能墙加工、组合判断、保留冒险、结算及胜负闭环。

## Requirements

### Requirement: Tutorial table has a reproducible complete setup
原 M2 固定 Seed 教程桌 SHALL 继续作为可独立进入的规则教学与回归入口，不因三桌 Run 被删除。主入口 SHALL 提供中文的“教程”和“开始巡回”选择；教程重置仍恢复完全相同初态。

#### Scenario: Resetting the tutorial
- **WHEN** 玩家在任意阶段选择重置教程桌
- **THEN** 球体、状态、球槽、墙充能、分数、杆数、Seed 和阶段 SHALL 恢复声明初态

#### Scenario: Starting setup supports the core loop
- **WHEN** 教程桌首次加载
- **THEN** 该固定配置 SHALL 继续支持物理收球、功能墙加工和有效组合结算

#### Scenario: Player opens the main entry
- **WHEN** M3 候选启动
- **THEN** 玩家 SHALL 能用中文明确选择教程或三桌 Run，且两者使用同一 M1/M2 规则实现

### Requirement: Core state and available actions are always visible
可玩界面 SHALL 继续清晰显示 M2 核心状态，并在 M3 增加最多五枚有序徽章、触发预览、最终得分公式、道具栏、当前桌/Run 进度与奖励入口。默认玩家可见文字 SHALL 使用简体中文；内部规则 ID 不得直接作为标签显示。

#### Scenario: Player is aiming
- **WHEN** 球桌处于瞄准状态
- **THEN** 界面 SHALL 用中文显示目标分、当前分、剩余杆数、力度、辅助模式、Build、道具和可用出杆动作

#### Scenario: Player is deciding after a shot
- **WHEN** 球桌处于杆后决策状态
- **THEN** 界面 SHALL 用中文突出最佳组合、参与/污染槽位、M2 基础分、徽章步骤、最终分及合法结算/保留/道具动作

#### Scenario: Wall effect changes a slot
- **WHEN** 复制或染色效果修改当前球组
- **THEN** 对应实体、墙体、槽位与徽章预览 SHALL 提供中文可追踪反馈且与规则快照一致

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
