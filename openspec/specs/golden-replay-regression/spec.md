# golden-replay-regression Specification

## Purpose

定义物理与墙体规则的可执行回归证据，使固定案例能在本地和 CI 中复现、比较、定位漂移，并明确跨版本兼容边界。

## Requirements


### Requirement: Versioned replay input
每条 Golden Replay 案例 SHALL 记录 schema 版本、物理版本、内容版本、Seed、完整初始快照和出杆输入；缺失必需字段的案例不得执行。

#### Scenario: Load a valid replay
- **WHEN** 案例包含全部必需字段且版本受支持
- **THEN** 系统 SHALL 从记录的快照和输入执行回放，不得依赖场景节点的当前状态

#### Scenario: Missing required field
- **WHEN** 案例缺少物理版本、初始快照或出杆输入
- **THEN** 系统 SHALL 返回结构化失败结果并指出缺失字段

#### Scenario: Unsupported physics version
- **WHEN** 案例声明当前运行器不支持的物理版本
- **THEN** 系统 SHALL 拒绝比较，不得把版本差异误报为普通回归失败

### Requirement: Structured deterministic replay output
每次回放 SHALL 输出有序碰撞事件、库边与功能墙事件、最终球状态、tick 数、停止原因和规范化状态 Hash。

#### Scenario: Successful replay
- **WHEN** 一个合法案例运行到停止
- **THEN** 输出 SHALL 包含案例 ID、成功状态、事件、最终状态、tick 数、停止原因和状态 Hash

#### Scenario: Non-finite state
- **WHEN** 模拟中出现 NaN、无穷速度或无效位置
- **THEN** 回放 SHALL 立即失败并输出首个异常 tick 与相关球 ID

### Requirement: Golden comparison
案例 SHALL 能保存预期规则摘要，并在实际输出与预期不同时提供可定位的结构化差异；表现层像素差异不得参与规则 Hash。

#### Scenario: Matching golden case
- **WHEN** 实际事件摘要、最终状态、tick 数和 Hash 与预期一致
- **THEN** 案例 SHALL 通过

#### Scenario: Divergent final state
- **WHEN** 任一球的最终规则状态与预期不同
- **THEN** 案例 SHALL 失败并指出首个不同球及不同字段

#### Scenario: Event-order divergence
- **WHEN** 事件集合相同但发生顺序不同
- **THEN** 案例 SHALL 失败并指出首个不同事件索引

### Requirement: Regression suite coverage
M1 验收前 SHALL 建立 15 至 20 条固定案例，覆盖直撞、斜碰、擦碰、多球连撞、库边、角落、低速停止、最大力度、重叠修正、复制墙、染色墙和预测首碰。

#### Scenario: CI coverage audit
- **WHEN** CI 运行 Golden Replay 套件
- **THEN** 套件 SHALL 校验案例数量与必需类别，缺少任一类别 SHALL 失败

### Requirement: Cross-platform evidence
Windows 与 Linux CI SHALL 使用相同案例和锁定的 Godot 版本运行回放，并 SHALL 比较规范化规则结果。

#### Scenario: Cross-platform match
- **WHEN** Windows 与 Linux 对同一案例产生相同规范化事件和最终规则状态
- **THEN** 跨平台检查 SHALL 通过

#### Scenario: Cross-platform divergence
- **WHEN** 两个平台的规范化规则结果不同
- **THEN** 检查 SHALL 失败并保留两端结构化输出；不得以容差静默吞掉会改变碰撞顺序或墙体归属的差异

### Requirement: Evidence does not claim game feel
Golden Replay 和重复运行结果 SHALL 只作为规则稳定与可复现证据，不得作为手感优秀或游戏好玩的验收结论。

#### Scenario: All automated checks pass
- **WHEN** 所有 Golden Replay、重复运行与跨平台检查通过
- **THEN** M1 仍 SHALL 要求真人完成与网页原型的手感对照后才能通过体验门
